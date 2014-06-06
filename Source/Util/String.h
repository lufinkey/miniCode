
#include <string>

#pragma once

class String
{
private:
	char*characters;
	int total;
	
	std::string intToString(const int num) const;
	std::string uintToString(const unsigned int num) const;
	std::string floatToString(const float num) const;
	std::string doubleToString(const double num) const;
	std::string longToString(const long num) const;
	
public:
	static bool asBool(const String&str);
	static int asInt(const String&str);
	static long asLong(const String&str);
	static short asShort(const String&str);
	static float asFloat(const String&str);
	static double asDouble(const String&str);
	static long long asLongLong(const String&str);
	static unsigned int asUInt(const String&str);
	static unsigned char asUChar(const String&str);
	static unsigned long asULong(const String&str);
	static unsigned short asUShort(const String&str);
	static unsigned long long asULongLong(const String&str);

	String();
	String(const String& str);
	String(const std::string&str);
	String(const char*str);
	String(const wchar_t*str);
	String(const std::wstring&str);
	String(const char c);
	String(const unsigned char num);
	String(const bool b);
	String(const int num);
	String(const unsigned int num);
	String(const float num);
	String(const double num);
	String(const long num);
	virtual ~String();

	operator char*();
	operator const char*();
	operator std::string();
	operator std::wstring();
	operator char*() const;
	operator const char*() const;
	operator std::string() const;
	operator std::wstring() const;

	String operator+(const String& str) const;
	String operator+(const std::string& str) const;
	String operator+(const char*str) const;
	String operator+(const wchar_t*str) const;
	String operator+(const std::wstring& str) const;
	String operator+(const bool b) const;
	String operator+(const char c) const;
	String operator+(const unsigned char num) const;
	String operator+(const int num) const;
	String operator+(const unsigned int num) const;
	String operator+(const long num) const;
	String operator+(const float num) const;
	String operator+(const double num) const;

	String& operator+=(const String& str);
	String& operator+=(const std::string& str);
	String& operator+=(const char*str);
	String& operator+=(const wchar_t*str);
	String& operator+=(const std::wstring str);
	String& operator+=(const bool b);
	String& operator+=(const char c);
	String& operator+=(const unsigned char num);
	String& operator+=(const int num);
	String& operator+=(const unsigned int num);
	String& operator+=(const long num);
	String& operator+=(const float num);
	String& operator+=(const double num);

	String& operator=(const String& str);
	String& operator=(const std::string& str);
	String& operator=(const char*str);
	String& operator=(const wchar_t*str);
	String& operator=(const std::wstring& str);
	String& operator=(const bool b);
	String& operator=(const char c);
	String& operator=(const unsigned char num);
	String& operator=(const int num);
	String& operator=(const unsigned int num);
	String& operator=(const long num);
	String& operator=(const float num);
	String& operator=(const double num);

	bool operator==(String& cmp);
	bool operator==(const char*cmp);

	friend std::ostream& operator<<(std::ostream& stream, const String& str);

	bool equals(const String& cmp) const;
	bool equals(const char*cmp) const;
	
	int compare(const String& cmp) const;
	
	void clear();
	int length() const;
	char charAt(int index) const;
	void replace(const String&find, const String&rep);
	String substring(int beginIndex) const;
	String substring(int beginIndex, int endIndex) const;
	String trim() const;
	int indexOf(const String&str) const;
	int lastIndexOf(const String&str) const;
	String toLowerCase();
	String toUpperCase();
};