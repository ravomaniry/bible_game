function gzipTxt(lines) {
    const sequences = extractSequences(lines);
    const header = Buffer.from(sequences.join(' '), 'utf8');
    const body = binaryStringToBytes(formatBody(lines, sequences));
    return Buffer.concat([header, body]);
}


function extractSequences(lines) {
    let totalLength = lines.map((x) => x.length).reduce((a, b) => a + b);
    const chars = ['__'].concat(extractChars(lines));
    const allSequences = countCharCombinations(lines, chars, 2);
    const sequences = chars;
    for (const sequence of allSequences) {
        const delta = getSequenceDelta(sequence, sequences, totalLength);
        if (delta < 0) {
            sequences.push(sequence.value);
            totalLength += delta;
        }
    }
    return sequences.sort((a, b) => b.length - a.length);
}


function formatBody(lines, sequences) {
    console.log('formatBody');
    const charSize = getCharSize(sequences);
    const separator = addZeroes('0', charSize);
    let binayString = separator;
    lines.forEach((line, i) => {
        const indexes = lineToSequenceIndexes(line, sequences);
        const binaries = indexes.map((index) => addZeroes(index.toString(2), charSize)).join('');
        binayString += binaries + separator;
        if (i % 1000 === 0) {
            console.log('   ', i);
        }
    });
    return binayString;
}

function addZeroes(str, charSize) {
    while (str.length < charSize) {
        str = '0' + str;
    }
    return str;
}


function binaryStringToBytes(binaryStr) {
    binaryStr += '0'.repeat(8 - binaryStr.length % 8)
    const length = binaryStr.length / 8;
    const buffer = Buffer.alloc(length);
    for (let i = 0; i < length; i++) {
        const str = binaryStr.substring(i * 8, i * 8 + 1);
        buffer[i] = parseInt(str, 2);
    }
    return buffer;
}


function lineToSequenceIndexes(line, sequences) {
    const indexes = [];
    let remaining = line;
    while (remaining) {
        let foundMatch = false;
        for (let i = 0, max = sequences.length; i < max; i++) {
            if (remaining.startsWith(sequences[i])) {
                indexes.push(i);
                remaining = remaining.substring(sequences[i].length);
                foundMatch = true;
                break;
            }
        }
        if (!foundMatch) {
            remaining = remaining.substring(1);
        }
    }
    return indexes;
}

function extractChars(lines) {
    const chars = [];
    for (const line of lines) {
        for (const char of Array.from(line)) {
            if (!chars.includes(char)) {
                chars.push(char);
            }
        }
    }
    return chars;
}

/**
 *
 * @param {string[]} lines
 * @param {string[]} chars
 * @param {number} length
 */
function countCharCombinations(lines, chars, length) {
    console.log('countCharCombinations');
    const occurences = new Map();
    const sequences = getCharCombinations(chars, length);
    for (let i = lines.length - 1; i >= 0; i--) {
        const line = lines[i];
        for (const seq of sequences) {
            const matches = line.split(seq).length - 1;
            if (matches) {
                occurences.set(seq, (occurences.get(seq) || 0) + matches);
            }
        }
        if (i % 1000 === 0) {
            console.log('  ', i);
        }
    }
    const count = [];
    occurences.forEach((n, value) => count.push({ n, value }));
    count.sort((a, b) => b.n - a.n);
    return count;
}


function getCharCombinations(chars, length) {
    let sequences = Array.from(chars);
    for (let gen = 1; gen < length; gen++) {
        const tmp = sequences;
        sequences = [];
        for (const seq of tmp) {
            for (const char of chars) {
                sequences.push(seq + char);
            }
        }
    }
    return sequences;
}


function getSequenceDelta(sequence, sequences, totalLength) {
    const currentSize = getTextSize(sequences, totalLength);
    const length = sequence.value.length;
    const nextLength = totalLength - (length - 1) * sequence.n;
    const nextSize = getTextSize(sequences.concat([sequence.value]), nextLength);
    return nextSize - currentSize;
}

function getTextSize(chars, totalLength) {
    const header = 8 * chars.map((x) => x.length + 1).reduce((a, b) => a + b);
    const body = getCharSize(chars.length) * totalLength;
    return header + body;
}

function getCharSize(charsCount) {
    let size = 0;
    while (Math.pow(2, size) < charsCount) {
        size++;
    }
    return size;
}


module.exports = {
    gzipTxt,
    getTextSize,
    getCharSize,
    getCharCombinations,
    countCharCombinations,
    getSequenceDelta,
    extractSequences,
    lineToSequenceIndexes,
}
