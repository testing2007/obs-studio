////
////  obs-file.cpp
////  obs-test
////
////  Created by ZhiQiang wei on 2020/11/18.
////
//
//#include "obs-file.hpp"
/////Users/zhiqiangwei/Work/openSource/obs-studio/libobs/util/platform.h
//static void FindBestFilename(string &strPath, bool noSpace)
//{
//    int num = 2;
//
//    if (!os_file_exists(strPath.c_str()))
//        return;
//
//    const char *ext = strrchr(strPath.c_str(), '.');
//    if (!ext)
//        return;
//
//    int extStart = int(ext - strPath.c_str());
//    for (;;) {
//        string testPath = strPath;
//        string numStr;
//
//        numStr = noSpace ? "_" : " (";
//        numStr += to_string(num++);
//        if (!noSpace)
//            numStr += ")";
//
//        testPath.insert(extStart, numStr);
//
//        if (!os_file_exists(testPath.c_str())) {
//            strPath = testPath;
//            break;
//        }
//    }
//}
//
//
//static void ensure_directory_exists(string &path)
//{
//    replace(path.begin(), path.end(), '\\', '/');
//
//    size_t last = path.rfind('/');
//    if (last == string::npos)
//        return;
//
//    string directory = path.substr(0, last);
//    os_mkdirs(directory.c_str());
//}
//
//string GenerateSpecifiedFilename(const char *extension, bool noSpace,
//                 const char *format)
//{
//    BPtr<char> filename =
//        os_generate_formatted_filename(extension, !noSpace, format);
//    return string(filename);
//}
//
//string GetOutputFilename(const char *path, const char *ext, bool noSpace,
//             bool overwrite, const char *format)
//{
//    OBSBasic *main = reinterpret_cast<OBSBasic *>(App()->GetMainWindow());
//
//    os_dir_t *dir = path && path[0] ? os_opendir(path) : nullptr;
//
//    if (!dir) {
//        if (main->isVisible())
//            OBSMessageBox::warning(main,
//                           QTStr("Output.BadPath.Title"),
//                           QTStr("Output.BadPath.Text"));
//        else
//            main->SysTrayNotify(QTStr("Output.BadPath.Text"),
//                        QSystemTrayIcon::Warning);
//        return "";
//    }
//
//    os_closedir(dir);
//
//    string strPath;
//    strPath += path;
//
//    char lastChar = strPath.back();
//    if (lastChar != '/' && lastChar != '\\')
//        strPath += "/";
//
//    strPath += GenerateSpecifiedFilename(ext, noSpace, format);
//    ensure_directory_exists(strPath);
//    if (!overwrite)
//        FindBestFilename(strPath, noSpace);
//
//    return strPath;
//}
//
//std::string
//BasicOutputHandler::GetRecordingFilename(const char *path, const char *ext,
//                     bool noSpace, bool overwrite,
//                     const char *format, bool ffmpeg)
//{
//    bool remux = !ffmpeg && SetupAutoRemux(ext);
//    string dst = GetOutputFilename(path, ext, noSpace, overwrite, format);
//    lastRecordingPath = remux ? dst : "";
//    return dst;
//}
