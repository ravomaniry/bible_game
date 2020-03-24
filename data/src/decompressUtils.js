const { getCharSize, addZeroesBefore } = require('./doodleGzipUtils');


function extractSequences(rawWords) {
    return rawWords.split('_');
}

function decompress(sequences, body) {
    const charSize = getCharSize(sequences.length);
    let result = '';
    let bits = '';
    for (let i = 0, max = body.length; i < max; i++) {
        const byte = body[i];
        const bin = addZeroesBefore(parseInt(byte, 10).toString(2), 8);
        bits += bin;
        while (bits.length > charSize) {
            const index = parseInt(bits.substring(0, charSize), 2);
            result += sequences[index - 1] || '\n';
            bits = bits.substring(charSize);
        }
    }
    return result.trim();
}


module.exports = {
    extractSequences,
    decompress,
};
