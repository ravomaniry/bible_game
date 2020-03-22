const fs = require('fs')
const path = require('path')
const verses = JSON.parse(fs.readFileSync(path.join(__dirname, '..', 'full', 'baiboly.json')))
    .map(({ livre, chapitre, verset, text }) => ({
        book: livre,
        chapter: chapitre,
        verse: verset,
        text: text,
    }))

extractAndReplaceBooks(verses)

function extractAndReplaceBooks(verses) {
    const books = []
    const bookNames = []
    const bookChapters = []
    for (const verse of verses) {
        const { book, chapter } = verse
        let bookIndex = bookNames.indexOf(book)
        if (bookIndex === -1) {
            bookIndex = books.length
            bookNames.push(book)
            books.push({ id: books.length + 1, name: book, chapters: 1 })
            bookChapters.push([chapter])
        }
        verse.book = bookIndex + 1
        if (!bookChapters[bookIndex].includes(chapter)) {
            bookChapters[bookIndex].push(chapter)
            books[bookIndex].chapters++
        }
    }
    console.log(bookChapters)
    fs.writeFileSync(path.join(__dirname, '..', 'output', 'books.json'), JSON.stringify(books))
    fs.writeFileSync(path.join(__dirname, '..', 'output', 'verses.json'), JSON.stringify(verses))
}
