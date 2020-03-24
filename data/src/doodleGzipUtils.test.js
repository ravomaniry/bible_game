const { gzipTxt, countCharCombinations, getCharCombinations, getCharSize,
    getSequenceDelta, getTextSize, extractSequences, lineToSequenceIndexes,
} = require('./doodleGzipUtils');


it('getCharSize', () => {
    expect(getCharSize(2)).toEqual(2);
    expect(getCharSize(3)).toEqual(2);
    expect(getCharSize(5)).toEqual(3);
    expect(getCharSize(10)).toEqual(4);
});


it('All sequences', () => {
    expect(getCharCombinations(['a', 'b'], 3, ['aaa bbb bba'])).toEqual([
        'aaa',
        'bba',
        'bbb'
    ]);
});


it('countSequences', () => {
    const lines = ['ababcba', 'bbabc'];
    const chars = ['a', 'b', 'c'];
    expect(countCharCombinations(lines, chars, [2, 3])).toEqual([
        { value: 'ba', n: 3 },
        { value: 'ab', n: 3 },
        { value: 'bab', n: 2 },
        { value: 'abc', n: 2 },
        { value: 'bba', n: 1 },
        { value: 'cba', n: 1 },
        { value: 'bcb', n: 1 },
        { value: 'aba', n: 1 },
    ]);
});


it('getTextSize', () => {
    const chars = ['a', 'b', 'c'];
    const totalLength = 20;
    expect(getTextSize(chars, totalLength)).toEqual(80);
});


it('getSequenceDelta', () => {
    const totalLength = 100;
    const nextLength = 70;
    const chars = ['a', 'b'];
    const current = 8 * 6 + totalLength * 2;
    const next = 8 * 9 + nextLength * 2;
    expect(getSequenceDelta({ value: 'aa', n: 30 }, chars, totalLength)).toEqual(next - current);
});


it('Extract sequences', () => {
    const lines = Array(100).fill('aa aa aa aa b aa');
    expect(extractSequences(lines)).toEqual([" aa ",
        'a aa',
        'aa a',
        'b aa',
        ' b a',
        'a b ',
        'aa b',
        ' aa',
        'aa ',
        'a a',
        'a',
        ' ',
        'b'
    ]);
});

it('lineToSequenceIndexes', () => {
    const sequences = ['aa', 'a', 'b'];
    expect(lineToSequenceIndexes('aaa', sequences)).toEqual([1, 2]);
    expect(lineToSequenceIndexes('ba aa', sequences)).toEqual([3, 2, 1]);
});


it('Compress', () => {
    const lines = ['abcabc', 'abc']; // 2 bits - 01101101101100
    const { header, body } = gzipTxt(lines);
    expect(header).toEqual('a_b_c');
    expect(body.length).toEqual(3);
    expect(body[0]).toEqual(parseInt('01101101', 2)); // a:01 b:10 c:11 a:01
    expect(body[1]).toEqual(parseInt('10110001', 2)); // b:10 c:11 sep: 00 a:01
    expect(body[2]).toEqual(parseInt('10110000', 2)); // b:10 c:11 0000
});
