const fs = require('fs');
const path = require('path');


async function uniqueChars() {
    const start = new Date().getTime();
    const content = await fs.promises.readFile(path.join(__dirname, '..', 'full', 'verses.json'));
    const verses = JSON.parse(content);
    const chars = [];
    for (const { text } of verses) {
        const lower = text.toLowerCase();
        for (let i = text.length - 1; i >= 0; i--) {
            const char = lower.charCodeAt(i);
            if (!chars.includes(char)) {
                chars.push(char);
            }
        }
    }
    console.log(chars.map((x) => String.fromCharCode(x)).sort().join(''));
    console.log('Done in ', new Date().getTime() - start, 'ms');
}

uniqueChars();
