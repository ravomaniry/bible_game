const fs = require('fs');
const path = require('path');
const { gzipTxt } = require('./doodleGzipUtils');

function compressVerses() {
    const content = fs.readFileSync(path.join(__dirname, '..', 'full', 'verses.json'), 'utf8');
    const verses = JSON.parse(content);
    const lines = verses.map(({ book, chapter, verse, text }) =>
        `${book} ${chapter} ${verse} ${text}`
    );
    const data = gzipTxt(lines);
    fs.writeFileSync(path.join(__dirname, '..', 'output', 'compressed'), data);
}

compressVerses();
