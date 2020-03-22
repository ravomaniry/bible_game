const { extractWords, compressVerses } = require('./compressUtils');


it('Extract, compress words', async () => {
    const verses = [
        { book: 1, chapter: 1, verse: 1, text: 'Tamin\'ny faharoa, Tamin\'ny faharoa.' },
        { book: 1, chapter: 1, verse: 2, text: 'Tamin\'ny faharoa, dia tamin\'ny \n faharoa ...' },
    ];
    const words = ['faharoa', 'Tamin'];
    expect(extractWords(verses)).toEqual(words);
    expect(compressVerses(verses)).toEqual({
        words,
        verses: [
            '1 1 1 _1\'ny _0, _1\'ny _0.',
            '1 1 2 _1\'ny _0, dia tamin\'ny _0 ...',
        ]
    });
});
