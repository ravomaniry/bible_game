const fs = require('fs');
const path = require('path');
const readline = require('readline');
const rl = readline.createInterface({
    input: process.stdin,
    output: process.stdout,
    terminal: false
});

const lines = [];


rl.on('line', (line) => {
    if (line.includes('Date')) {
        lines.push(line.substring(line.indexOf('Date') + 6).trim());
    }
});

setTimeout(() => {
    fs.writeFileSync(path.join(__dirname, 'git_log.txt'), lines.join('\n'));
}, 1500);
