const fs = require('fs');
const path = require('path');
const { extractSequences, decompress } = require('./decompressUtils');


function decompressVerses() {
    const folderPath = path.join(__dirname, '..', 'output');
    const rawSequences = fs.readFileSync(`${folderPath}/verse_words.txt`, 'utf8');
    const body = fs.readFileSync(`${folderPath}/verses.ddlzip`);
    const sequences = extractSequences(rawSequences);
    const result = decompress(sequences, body);
    fs.writeFileSync(`${folderPath}/1.txt`, result, 'utf8');
}


decompressVerses();
