const fs = require('fs');
const path = require('path');
const { gzipTxt } = require('./doodleGzipUtils');

function compressVerses() {
    const content = fs.readFileSync(path.join(__dirname, '..', 'full', 'verses.json'), 'utf8');
    const verses = JSON.parse(content);
    const lines = verses.map(({ book, chapter, verse, text }) =>
        `${book} ${chapter} ${verse} ${text}`
    );
    const { header, body } = gzipTxt(lines);
    fs.writeFileSync(path.join(__dirname, '..', 'output', 'verse_words.txt'), header, 'utf8');
    fs.writeFileSync(path.join(__dirname, '..', 'output', 'verses.nothing'), body);
}

compressVerses();
