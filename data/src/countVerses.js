const fs = require('fs');

const verses = JSON.parse(fs.readFileSync(__dirname + '/new_testament_verses.json', 'utf8'));
const books = JSON.parse(fs.readFileSync(__dirname + '/new_testament_books.json', 'utf8'));
const counts = {};
const chars = {};

for (const { book, text } of verses) {
    const bookName = books.find((b) => b.id === book).name;
    counts[bookName] = (counts[bookName] || 0) + 1;
    chars[bookName] = (chars[bookName] || 0) + text.split(' ').length;
}

console.log(counts);
console.log(books);
