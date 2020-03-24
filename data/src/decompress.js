const fs = require('fs');
const path = require('path');


function decompress() {
    const words = fs.readFileSync(path.join(__dirname, '..', 'output', 'verse_words.txt'), 'utf8');
    const compressed = fs.readFileSync(path.join(__dirname, '..', 'output', 'verses.nothing'));
    let binary = '';

}
