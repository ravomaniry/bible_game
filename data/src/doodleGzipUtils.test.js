const { gzipTxt, countCharCombinations, getCharCombinations, getCharSize,
    getSequenceDelta, getTextSize, extractSequences, lineToSequenceIndexes,
} = require('./doodleGzipUtils');


it('getCharSize', () => {
    expect(getCharSize(2)).toEqual(1);
    expect(getCharSize(3)).toEqual(2);
    expect(getCharSize(5)).toEqual(3);
    expect(getCharSize(10)).toEqual(4);
});


it('All sequences', () => {
    expect(getCharCombinations(['a', 'b'], 3)).toEqual([
        'aaa',
        'aab',
        'aba',
        'abb',
        'baa',
        'bab',
        'bba',
        'bbb'
    ]);
});


it('countSequences', () => {
    const lines = ['ab abc ba', 'bb bc'];
    const chars = ['a', 'b', 'c'];
    const length = 2;
    expect(countCharCombinations(lines, chars, length)).toEqual([
        { value: 'ab', n: 2 },
        { value: 'bc', n: 2 },
        { value: 'ba', n: 1 },
        { value: 'bb', n: 1 },
    ]);
});


it('getTextSize', () => {
    const chars = ['a', 'b', 'c'];
    const totalLength = 20;
    expect(getTextSize(chars, totalLength)).toEqual(8 * 6 + 2 * 20);
});


it('getSequenceDelta', () => {
    const totalLength = 100;
    const nextLength = 70;
    const chars = ['a', 'b', ' '];
    const current = 8 * 6 + totalLength * 2;
    const next = 8 * 9 + nextLength * 2;
    expect(getSequenceDelta({ value: 'aa', n: 30 }, chars, totalLength)).toEqual(next - current);
});


it('Extract sequences', () => {
    const lines = Array(10).fill('aa aa b aa');
    expect(extractSequences(lines)).toEqual(['aa', 'a', ' ', 'b']);
})

it('lineToSequenceIndexes', () => {
    const sequences = ['aa', 'a', 'b'];
    expect(lineToSequenceIndexes('aaa', sequences)).toEqual([0, 1]);
    expect(lineToSequenceIndexes('ba aa', sequences)).toEqual([2, 1, 0]);
});
