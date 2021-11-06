// Copyright (c) 2010-2011 Zipline Games, Inc. All Rights Reserved.
// http://getmoai.com

#ifndef	HTMLHOST
#define	HTMLHOST

//----------------------------------------------------------------//
extern "C" {

  void RefreshContext();
  void Cleanup();

  //----------------------------------------------------------------//
  void onKeyDown ( int key );

  //----------------------------------------------------------------//
  void onKeyUp ( int key );

  //----------------------------------------------------------------//
  void onChar ( int unicodeChar );

  //----------------------------------------------------------------//
  void onMouseButton ( int button, int state );

  //----------------------------------------------------------------//
  void onMouseDrag ( int x, int y );

  //----------------------------------------------------------------//
  void onMouseMove ( int x, int y );

  //----------------------------------------------------------------//
  void onPaint ();

  //----------------------------------------------------------------//
  void onReshape ( int w, int h );

  //----------------------------------------------------------------//
  void onTimer ();

  //----------------------------------------------------------------//
  void showRuntimeInfo();

  // int akuSetWorkingDirectory ( char const* path );
  // double akuGetSimStep ();
  // void akuEnqueueKeyboardKeyEvent (int deviceID, int sensorID, int keyID, bool down);
  // int akuLoadFuncFromString(const char *script, size_t size, const char *chunkname);
  // int akuLoadFuncFromFile(const char *filename);
  // int akuCallFunc();

  //js callbacks
  void EnterFullScreen();
  void ExitFullScreen();
  void OpenWindowFunc(const char* title, int width, int height);
  void RestoreFile(const char* path, int data);
  const char* CallStringFunc(char *func);
}



#endif
