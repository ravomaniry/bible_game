const fs = require('fs');
const path = require('path');
const { gzipTxt } = require('./doodleGzipUtils');


function test() {
    const lines = ['aa', 'ab', 'ac']; // 0101 00 01_10 00 0111 _ 00000000
    const { header, body } = gzipTxt(lines);
    console.log(parseInt(body[0], 10).toString(2));
    fs.writeFileSync(path.join(__dirname, '../output/1_seqs.txt'), header, 'utf8');
    fs.writeFileSync(path.join(__dirname, '../output/1.ddl'), body);
}

test();
