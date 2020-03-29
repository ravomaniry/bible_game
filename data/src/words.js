const path = require('path');
const fs = require('fs');
const separators = Array.from(' !"\'(),-.:;=?[]');


function logWordCounts() {
    const filePath = path.join(__dirname, '..', 'full', 'verses.json');
    const content = fs.readFileSync(filePath, 'utf8');
    const verses = JSON.parse(content);
    const count = new Map();
    let word = '';
    const increment = (book, chapter, verse) => {
        if (word) {
            let match = count.get(word);
            if (!match) {
                match = { num: 0, book, chapter, verse };
                count.set(word, match);
            }
            match.num++;
            word = '';
        }
    };
    for (const { book, chapter, verse, text } of verses) {
        for (let i = 0, length = text.length; i < length; i++) {
            if (separators.includes(text[i])) {
                increment(book, chapter, verse);
            } else {
                word += text[i].toLowerCase();
            }
        }
        increment();
    }
    formatResult(count);
    console.log('Done');
}


/**
 *
 * @param {Map<string,number>} count
 */
function formatResult(count) {
    const wordCounts = [];
    count.forEach((value, word) => {
        wordCounts.push({ word, ...value });
    });
    wordCounts.sort((a, b) => a.num - b.num);
    const txt = wordCounts.map(({ word, num, book, chapter, verse }) =>
        `${word} ${num} - ${book}:${chapter}:${verse}`
    ).join('\n');
    fs.writeFileSync(
        path.join(__dirname, '..', 'output', 'wordscounts.txt'),
        txt,
        'utf8'
    );
}

logWordCounts();
