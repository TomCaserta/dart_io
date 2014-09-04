part of DataBuffer;

class DataInput {
  Uint8List data;
  int _fileLength;
  ByteData view;
  int _offset = 0;
  int get offset => _offset;
  int get fileLength => _fileLength;
  
  DataInput.fromUint8List (this.data) {
    this.view = new ByteData.view(data.buffer);
    _fileLength = data.lengthInBytes;
  }
  
  DataInput.fromGZip (List<int> gZipBytes) {
    GZipDecoder decoder = new GZipDecoder();
    data = new Uint8List.fromList(decoder.decodeBytes(gZipBytes));
    view = new ByteData.view(data.buffer);
    _fileLength = data.lengthInBytes;
  }
  
  DataInput.fromZLib (List<int> zLibBytes) {
    ZLibDecoder decoder = new ZLibDecoder();
    List<int> decompressBytes = decoder.decodeBytes(zLibBytes);
    data = new Uint8List.fromList(decompressBytes);
    view = new ByteData.view(data.buffer);
    _fileLength = data.lengthInBytes;
  }
  
  
  /*** 
   * Returns the byte(-128 - 127) at [offset]. if [eofException] is false then 
   * if it reaches the end of the stream it will return -129. 
   * Otherwise it will throw an exception.
  */
  int readByte ([bool eofException = true]) {
    if (offset < fileLength) {
      return view.getInt8(_offset++);
    }
    else if (eofException) throw new RangeError("Reached end of file");
    else return -129;
  }
  
  List<int> readBytes(int numBytes) {
    if ((_offset + numBytes) < fileLength) {
      int old_offset = _offset;
      _offset += numBytes;
      return data.getRange(old_offset, old_offset + numBytes).toList();
    }
    else throw new RangeError("Reached end of file");  
  }
  /*** 
   * Returns the byte(0-255) at [offset]. if [eofException] is false then 
   * if it reaches the end of the stream it will return -1, Otherwise it will 
   * throw an exception.
  */
  int readUnsignedByte([bool eofException = true]) {
    if (offset < fileLength) {
      return view.getUint8(_offset++);
    }
    else if (eofException) throw new RangeError("Reached end of file");
    else return -129;
  }
  
  int readShort([Endianness endian = Endianness.BIG_ENDIAN]) {
    var old_offset = _offset;
    _offset += 2;
    return view.getInt16(old_offset, endian);
  }
  
  int readUnsignedShort([Endianness endian = Endianness.BIG_ENDIAN]) {
    var old_offset = _offset;
    _offset += 2;
    return view.getUint16(old_offset, endian);
  }
  

  int readInt([Endianness endian = Endianness.BIG_ENDIAN]) {
    var old_offset = _offset;
    _offset += 4;
    return view.getInt32(old_offset, endian);
  }

  List<int> readLong() {
      return readBytes(8);
  }
  
  double readFloat([Endianness endian = Endianness.BIG_ENDIAN]) {
    var old_offset = _offset;
    _offset += 4;
    return view.getFloat32(old_offset, endian);
   
  }
  

  double readDouble([Endianness endian = Endianness.BIG_ENDIAN]) {
    var old_offset = _offset;
    _offset += 8;
    return view.getFloat64(old_offset, endian);
  }
  

  String readLine([Endianness endian = Endianness.BIG_ENDIAN]) {
    var byte = readUnsignedByte(false);
    if (byte == -1) return null;

    bool isCR = false;
    StringBuffer result = new StringBuffer();
    while (byte != -1 && byte != 0x0A) {
      if (byte != 0x0D) {
        result.writeCharCode(byte);
      }
      byte = readUnsignedByte(false);
    }
    return result.toString();
  }
  
  
  String readChar([Endianness endian = Endianness.BIG_ENDIAN]) {
    return new String.fromCharCode(readShort(endian));
  }
   
  bool readBoolean () {
    return readByte() != 0;
  }
  
  void readFully(List bytes,{ int len, int off, Endianness endian: Endianness.BIG_ENDIAN }) {
    if (len != null || off != null) {
      if ((len != null && off == null) || (len == null && off != null)) throw new ArgumentError("You must supply both [len] and [off] values.");
      if (len < 0 || off < 0) throw new RangeError("$off - $len is out of bounds");
      if (len == 0) return;
    }
     
    if (len != null) {
      bytes.addAll(data.getRange(off, len));
    }
    else {
      fillList(bytes, readBytes(bytes.length));
    }
  }
 
  String readUTF([Endianness endian = Endianness.BIG_ENDIAN]) {
      int length = readShort(endian);
      List<int> bytes = readBytes(length);
      return UTF8.decode(bytes);
  }
  
  int skipBytes(int n) {
    // THANKS FOR THE GREAT DOCUMENTATION ORACLE:
    // Docs: However, it may skip over some smaller number of bytes, possibly zero. 
    // This may result from any of a number of conditions; reaching end of file before n bytes have been skipped is only one possibility. /:DOCS
    // 
    // Great, so you know... for some reason they dont bother to specify why it might skip.
    // So glad I dont write in java haha, I mean seriously wtf are you meant to do in that 
    // scenario. Just be like "Okay so you didnt skip the amount I asked and youre not gunna tell me why". 
    // Id probably just end up reading bytes instead to skip :/
    _offset += n;
    if (_offset > fileLength) {
      var change = _offset - fileLength;
      _offset = fileLength;
      return n - change;      
    }
    return n;
  }
}