const { extractSequences, decompress } = require('./decompressUtils');

it('extractSequences', () => {
    expect(extractSequences('a_b_ab')).toEqual(['a', 'b', 'ab']);
});


it('decompress', () => {
    const sequences = ['a', 'b', 'c']; // 2 bits
    // aabbc = 01 01 10 10 11
    const body = Buffer.alloc(2);
    body[0] = parseInt('01011010', 2);
    body[1] = parseInt('11000000', 2);
    expect(decompress(sequences, body)).toEqual('aabbc');
});
