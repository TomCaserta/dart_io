part of dart_io;

// TODO: Fix the UINT8LIST stuff below
class DataOutput {
  List<int> data = new List();
  int offset = 0;
  int get fileLength => data.length; 
  
  Uint8List _buffer = new Uint8List(8);
  ByteData _view;
  
  DataOutput() {
    _view = new ByteData.view(_buffer.buffer);
  }
  
  void write (List<int> bytes) {
    int blength = bytes.length;
    data.addAll(bytes);
    offset += blength;
  }
    
  void writeBoolean (bool v, [Endianness endian = Endianness.BIG_ENDIAN]) {
    writeByte(v ? 1 : 0, endian);
  }
  void writeByte(int v, [Endianness endian = Endianness.BIG_ENDIAN]) {
    data.add(v);
    offset += 1;
  }
      
  void writeChar(int v, [Endianness endian = Endianness.BIG_ENDIAN]) {
    writeShort(v, endian);
  }
  void writeChars(String s, [Endianness endian = Endianness.BIG_ENDIAN]) {
    for (int x = 0; x <= s.length; x++) {
      writeChar(s.codeUnitAt(x), endian);
    }
  }
  

  void writeFloat(double v, [Endianness endian = Endianness.BIG_ENDIAN]) {
    _view.setFloat32(0, v, endian);
    write(_buffer.getRange(0, 4).toList());
  }
  void writeDouble(double v, [Endianness endian = Endianness.BIG_ENDIAN]) {
    _view.setFloat64(0, v, endian);
    write(_buffer.getRange(0, 8).toList());
  }

  void writeShort(int v, [Endianness endian = Endianness.BIG_ENDIAN]) {
    _view.setInt16(0, v, endian);
    write(_buffer.getRange(0, 2).toList());
  }
  void writeInt(int v, [Endianness endian = Endianness.BIG_ENDIAN]) {
    _view.setInt32(0, v, endian);
    write(_buffer.getRange(0, 4).toList());
  }
  void writeLong(List<int> v) {
    // TODO: Check if this messes up in dart2js
    write(v);
  }
  
  void writeUTF(String s, [Endianness endian = Endianness.BIG_ENDIAN]) {    
    if (s == null) throw new ArgumentError("String cannot be null");
    List<int> bytesNeeded = UTF8.encode(s);
    if (bytesNeeded.length > 65535) throw new FormatException("Length cannot be greater than 65535");
    writeShort(bytesNeeded.length, endian);
    write(bytesNeeded);
  }
  
  List<int> getBytes () {
    return data;
  }
  
  List<int> getBytesGZip () {
    GZipEncoder ginf = new GZipEncoder();
    return ginf.encode(data);
  }
  
  List<int> getBytesZLib () {
    ZLibEncoder zenc = new ZLibEncoder();
    return zenc.encode(data);
  }
}