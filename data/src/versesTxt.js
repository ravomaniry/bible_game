const fs = require('fs');
const path = require('path');


function versesToTxt() {
    const content = fs.readFileSync(path.join(__dirname, '../full/verses.json'), 'utf8');
    const verses = JSON.parse(content);
    const output = verses.map(({ book, chapter, verse, text }) =>
        `${book} ${chapter} ${verse} ${text}`
    ).join('\n');
    console.log(output.length);
    fs.writeFileSync(path.join(__dirname, '../output/verses.txt'), output, 'utf8');
}


versesToTxt();
