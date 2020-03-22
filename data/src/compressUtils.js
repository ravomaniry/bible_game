function extractWords(verses) {
    const wordCounts = new Map();
    for (const { text } of verses) {
        const newWords = getWordsInText(cleanString(text));
        for (const word of newWords) {
            const count = wordCounts.get(word) || 0;
            wordCounts.set(word, count + 1);
        }
    }
    const words = [];
    wordCounts.forEach((count, word) => appendWord(word, count, words));
    words.sort((a, b) => wordCounts.get(b) - wordCounts.get(a));
    return words;
}


function appendWord(word, count, words) {
    const replaced = `_${words.length.toString(36)}`;
    if (word.length * count > word.length + 1 + replaced.length * count) {
        words.push(word);
    }
}


function replaceVersesWords(verses, words) {
    return verses.map(({ book, chapter, verse, text }) =>
        `${book} ${chapter} ${verse} ${replaceWords(text, words)}`
    );
}


/**
 *
 * @param {string} text
 * @param {string[]} allWords
 */
function replaceWords(text, allWords) {
    text = cleanString(text);
    const words = getWordsInText(text);
    let remainingText = text;
    let replaced = '';
    for (const word of words) {
        const charIndex = remainingText.indexOf(word);
        if (charIndex > 0) {
            replaced += remainingText.substring(0, charIndex);
        }
        const index = allWords.indexOf(word);
        replaced += index >= 0 ? `_${index.toString(36)}` : word;
        remainingText = remainingText.substring(charIndex + word.length);
    };
    replaced += remainingText;
    return replaced;
}


function compressVerses(verses) {
    const words = extractWords(verses);
    console.log(words.length, 'words');
    const replacedVerses = replaceVersesWords(verses, words);
    return { words, verses: replacedVerses };
}


const wordRegex = /[a-z0-9àäèìïòô]+/gi;
function getWordsInText(text) {
    return text.match(wordRegex) || [];
}


function cleanString(value) {
    return value.replace(/_|\n/g, ' ').replace(/ +/g, ' ').trim();
}


module.exports = {
    extractWords,
    compressVerses,
    replaceVersesWords,
}
