const path = require('path');
const fs = require('fs');
const { compressVerses } = require('./compressUtils');


function runScript() {
    const verses = require('../full/verses.json');
    const compressed = compressVerses(verses);
    fs.writeFileSync(
        path.join(__dirname, '..', 'output', 'verses.txt'),
        `${compressed.words.join(' ')}\n${compressed.verses.join('\n')}`,
        'utf8'
    );
}


runScript();


module.exports = {
    compressVerses,
}
