const { extractSequences } = require('./decompressUtils');

it('extractSequences', () => {
    expect(extractSequences('a_b_ab')).toEqual(['a', 'b', 'ab']);
});
