part of dart_io;


List<int> byte2bit (int byte) {
  List<int> bitarr = new List<int>(8);
  for(int i = 0; i < 8; ++i) {
    bitarr[i] = (byte >> i) & 1;
  }
  return bitarr;
}

int bit2byte (List<int> bits) {
  return (bits[0] * 1) + 
         (bits[1] * 2) + 
         (bits[2] * 4) + 
         (bits[3] * 8) + 
         (bits[4] * 16) + 
         (bits[5] * 32) + 
         (bits[6] * 64) + 
         (bits[7] * 128);
}

void fillList (List one, List two) {
  for (int x = 0; x < one.length; x++) {
    if (x >= two.length) return;
    one[x] = two[x];
  }
}