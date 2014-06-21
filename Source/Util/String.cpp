
#define _CRT_SECURE_NO_WARNINGS

#include "String.h"
#include <iostream>
#include <sstream>
#include <vector>
#include <iomanip>
#include <stdlib.h>
#include "stdio.h"
#include <math.h>

long long string_powll(const long long base, const int exp)
{
	if(exp==0)
	{
		return 1;
	}
	
	long long result = base;
	int absExp = abs(exp);
	
	for(int i=1; i<absExp; i++)
	{
		result = result*base;
	}
	
	if(exp<0)
	{
		result = 1/result;
	}
	
	return result;
}

unsigned long long string_powull(const unsigned long long base, const int exp)
{
	if(exp==0)
	{
		return 1;
	}
	
	unsigned long long result = base;
	int absExp = abs(exp);
	
	for(int i=1; i<absExp; i++)
	{
		result = result*base;
	}
	
	if(exp<0)
	{
		result = 1/result;
	}
	
	return result;
}

bool String::asBool(const String&str)
{
	bool onlyNums = true;
	bool hasNum = false;
	bool hasDecimal = false;

	for(int i=0; i<str.length(); i++)
	{
		char c = str.charAt(i);
		if(!(c>='0' && c<='9'))
		{
			if(c=='.')
			{
				if(onlyNums && hasDecimal)
				{
					std::cerr << "Error: invalid String in function String::asBool(\"" << str << "\")" << std::endl;
					return false;
				}
				else if(onlyNums)
				{
					hasDecimal = true;
				}
			}
			else if(hasNum)
			{
				std::cerr << "Error: invalid String in function String::asBool(\"" << str << "\")" << std::endl;
				return false;
			}
			else
			{
				onlyNums = false;
			}
		}
		else
		{
			hasNum = true;
		}
	}

	if(onlyNums)
	{
		if(hasDecimal)
		{
			double d = asDouble(str);
			if(d>=1)
			{
				return true;
			}
			else
			{
				return false;
			}
		}
		else
		{
			long l = asLong(str);
			if(l>=1)
			{
				return true;
			}
			else
			{
				return false;
			}
		}
	}
	else if(hasNum)
	{
		std::cerr << "Error: invalid String in function String::asBool(\"" << str << "\")" << std::endl;
		return false;
	}
	else
	{
		if(str.equals("true") || str.equals("TRUE") || str.equals("on") || str.equals("ON") || str.equals("yes") || str.equals("YES"))
		{
			return true;
		}
		else if(str.equals("false") || str.equals("FALSE") || str.equals("off") || str.equals("OFF") || str.equals("no") || str.equals("NO"))
		{
			return false;
		}
		else
		{
			std::cerr << "Error: invalid String in function String::asBool(\"" << str << "\")" << std::endl;
			return false;
		}
	}
}

int String::asInt(const String&str)
{
	for(int i=0; i<str.length(); i++)
	{
		char c = str.charAt(i);
		if(!((c>='0' && c<='9') || (c=='-' && i==0) || (c=='+' && i==0)))
		{
			std::cerr << "Error: invalid String in function String::asInt(\"" << str << "\")" << std::endl;
			return 0;
		}
	}

	int mult = 1;
	int startIndex = 0;
	if(str.charAt(0)=='-')
	{
		mult = -1;
		startIndex = 1;
	}
	else if(str.charAt(0)=='+')
	{
		mult = 1;
		startIndex = 1;
	}

	int counter = 0;
	int totalVal = 0;

	for(int i=(str.length()-1); i>=startIndex; i--)
	{
		char c = str.charAt(i);
		int value = (int)(c - '0');
		if(counter==0)
		{
			totalVal += value;
		}
		else
		{
			totalVal += (value*(int)pow((float)10,counter));
		}
		counter++;
	}

	return totalVal*mult;
}

long String::asLong(const String&str)
{
	for(int i=0; i<str.length(); i++)
	{
		char c = str.charAt(i);
		if(!((c>='0' && c<='9') || (c=='-' && i==0) || (c=='+' && i==0)))
		{
			std::cerr << "Error: invalid String in function String::asLong(\"" << str << "\")" << std::endl;
			return 0;
		}
	}

	int mult = 1;
	int startIndex = 0;
	if(str.charAt(0)=='-')
	{
		mult = -1;
		startIndex = 1;
	}
	else if(str.charAt(0)=='+')
	{
		mult = 1;
		startIndex = 1;
	}

	int counter = 0;
	long totalVal = 0;

	for(int i=(str.length()-1); i>=startIndex; i--)
	{
		char c = str.charAt(i);
		int value = (int)(c - '0');
		if(counter==0)
		{
			totalVal += value;
		}
		else
		{
			totalVal += ((long)value*(long)pow((long double)10,(int)counter));
		}
		counter++;
	}

	return totalVal*mult;
}

short String::asShort(const String&str)
{
	for(int i=0; i<str.length(); i++)
	{
		char c = str.charAt(i);
		if(!((c>='0' && c<='9') || (c=='-' && i==0) || (c=='+' && i==0)))
		{
			std::cerr << "Error: invalid String in function String::asShort(\"" << str << "\")" << std::endl;
			return 0;
		}
	}
	
	int mult = 1;
	int startIndex = 0;
	if(str.charAt(0)=='-')
	{
		mult = -1;
		startIndex = 1;
	}
	else if(str.charAt(0)=='+')
	{
		mult = 1;
		startIndex = 1;
	}
	
	int counter = 0;
	short totalVal = 0;
	
	for(int i=(str.length()-1); i>=startIndex; i--)
	{
		char c = str.charAt(i);
		int value = (short)(c - '0');
		if(counter==0)
		{
			totalVal += value;
		}
		else
		{
			totalVal += ((short)value*(short)pow((int)10,(int)counter));
		}
		counter++;
	}
	
	return (short)(totalVal*mult);
}

float String::asFloat(const String&str)
{
	bool hasDecimal = false;
	int decimalIndex = str.length();

	for(int i=0; i<str.length(); i++)
	{
		char c = str.charAt(i);
		if(!((c>='0' && c<='9') || (c=='-' && i==0) || (c=='+' && i==0)))
		{
			if(c=='.')
			{
				if(hasDecimal)
				{
					std::cerr << "Error: invalid String in function String::asFloat(\"" << str << "\")" << std::endl;
					return 0;
				}
				else
				{
					hasDecimal = true;
					decimalIndex = i;
				}
			}
			std::cerr << "Error: invalid String in function String::asFloat(\"" << str << "\")" << std::endl;
			return 0;
		}
	}

	int mult = 1;
	int startIndex = 0;
	if(str.charAt(0)=='-')
	{
		mult = -1;
		startIndex = 1;
	}
	else if(str.charAt(0)=='+')
	{
		mult = 1;
		startIndex = 1;
	}

	int counter = -1;
	float totalVal = 0;

	for(int i=(decimalIndex+1); i<str.length(); i++)
	{
		char c = str.charAt(i);
		int value = (int)(c - '0');
		totalVal += (float)(value*pow((float)10,counter));
		counter--;
	}

	counter = 0;

	for(int i=(decimalIndex-1); i>=startIndex; i--)
	{
		char c = str.charAt(i);
		int value = (int)(c - '0');
		if(counter==0)
		{
			totalVal += value;
		}
		else
		{
			totalVal += (float)(value*(int)pow((float)10,counter));
		}
		counter++;
	}

	return totalVal*mult;
}

double String::asDouble(const String&str)
{
	bool hasDecimal = false;
	int decimalIndex = str.length();

	for(int i=0; i<str.length(); i++)
	{
		char c = str.charAt(i);
		if(!((c>='0' && c<='9') || (c=='-' && i==0) || (c=='+' && i==0)))
		{
			if(c=='.')
			{
				if(hasDecimal)
				{
					std::cerr << "Error: invalid String in function String::asDouble(\"" << str << "\")" << std::endl;
					return 0;
				}
				else
				{
					hasDecimal = true;
					decimalIndex = i;
				}
			}
			else
			{
				std::cerr << "Error: invalid String in function String::asDouble(\"" << str << "\")" << std::endl;
				return 0;
			}
		}
	}

	int mult = 1;
	int startIndex = 0;
	if(str.charAt(0)=='-')
	{
		mult = -1;
		startIndex = 1;
	}
	else if(str.charAt(0)=='+')
	{
		mult = 1;
		startIndex = 1;
	}
	
	int counter = -1;
	double totalVal = 0;

	for(int i=(decimalIndex+1); i<str.length(); i++)
	{
		char c = str.charAt(i);
		int value = (int)(c - '0');
		totalVal += (double)(value*pow((double)10,counter));
		counter--;
	}

	counter = 0;

	for(int i=(decimalIndex-1); i>=startIndex; i--)
	{
		char c = str.charAt(i);
		int value = (int)(c - '0');
		if(counter==0)
		{
			totalVal += value;
		}
		else
		{
			totalVal += (value*(double)pow((double)10,counter));
		}
		counter++;
	}

	return totalVal*mult;
}

long long String::asLongLong(const String&str)
{
	for(int i=0; i<str.length(); i++)
	{
		char c = str.charAt(i);
		if(!((c>='0' && c<='9') || (c=='-' && i==0) || (c=='+' && i==0)))
		{
			std::cerr << "Error: invalid String in function String::asLongLong(\"" << str << "\")" << std::endl;
			return 0;
		}
	}
	
	int mult = 1;
	int startIndex = 0;
	if(str.charAt(0)=='-')
	{
		mult = -1;
		startIndex = 1;
	}
	else if(str.charAt(0)=='+')
	{
		mult = 1;
		startIndex = 1;
	}
	
	int counter = 0;
	long long totalVal = 0;
	
	for(int i=(str.length()-1); i>=startIndex; i--)
	{
		char c = str.charAt(i);
		int value = (int)(c - '0');
		if(counter==0)
		{
			totalVal += value;
		}
		else
		{
			totalVal += ((long long)value*(long long)string_powll((long long)10,(int)counter));
		}
		counter++;
	}
	
	return (long long)(totalVal*mult);
}

unsigned int String::asUInt(const String&str)
{
	for(int i=0; i<str.length(); i++)
	{
		char c = str.charAt(i);
		if(!(c>='0' && c<='9'))
		{
			std::cerr << "Error: invalid String in function String::asUInt(\"" << str << "\")" << std::endl;
			return 0;
		}
	}
	
	int startIndex = 0;
	
	int counter = 0;
	unsigned int totalVal = 0;
	
	for(int i=(str.length()-1); i>=startIndex; i--)
	{
		char c = str.charAt(i);
		unsigned int value = (unsigned int)(c - '0');
		if(counter==0)
		{
			totalVal += value;
		}
		else
		{
			totalVal += ((unsigned int)value*(unsigned int)pow((float)10,counter));
		}
		counter++;
	}
	
	return totalVal;
}

unsigned char String::asUChar(const String&str)
{
	for(int i=0; i<str.length(); i++)
	{
		char c = str.charAt(i);
		if(!(c>='0' && c<='9'))
		{
			std::cerr << "Error: invalid String in function String::asUChar(\"" << str << "\")" << std::endl;
			return 0;
		}
	}
	
	int startIndex = 0;
	
	int counter = 0;
	unsigned char totalVal = 0;
	
	for(int i=(str.length()-1); i>=startIndex; i--)
	{
		char c = str.charAt(i);
		unsigned char value = (unsigned char)(c - '0');
		if(counter==0)
		{
			totalVal += value;
		}
		else
		{
			totalVal += ((unsigned char)value*(unsigned char)pow((float)10,counter));
		}
		counter++;
	}
	
	return totalVal;
}

unsigned long String::asULong(const String&str)
{
	for(int i=0; i<str.length(); i++)
	{
		char c = str.charAt(i);
		if(!(c>='0' && c<='9'))
		{
			std::cerr << "Error: invalid String in function String::asULong(\"" << str << "\")" << std::endl;
			return 0;
		}
	}
	
	int startIndex = 0;
	
	int counter = 0;
	unsigned long totalVal = 0;
	
	for(int i=(str.length()-1); i>=startIndex; i--)
	{
		char c = str.charAt(i);
		unsigned int value = (unsigned int)(c - '0');
		if(counter==0)
		{
			totalVal += value;
		}
		else
		{
			totalVal += ((unsigned long)value*(unsigned long)pow((long double)10,(int)counter));
		}
		counter++;
	}
	
	return totalVal;
}

unsigned short String::asUShort(const String&str)
{
	for(int i=0; i<str.length(); i++)
	{
		char c = str.charAt(i);
		if(!(c>='0' && c<='9'))
		{
			std::cerr << "Error: invalid String in function String::asUShort(\"" << str << "\")" << std::endl;
			return 0;
		}
	}
	
	int startIndex = 0;
	
	int counter = 0;
	unsigned short totalVal = 0;
	
	for(int i=(str.length()-1); i>=startIndex; i--)
	{
		char c = str.charAt(i);
		unsigned short value = (unsigned short)(c - '0');
		if(counter==0)
		{
			totalVal += value;
		}
		else
		{
			totalVal += ((unsigned short)value*(unsigned short)pow((float)10,(int)counter));
		}
		counter++;
	}
	
	return totalVal;
}

unsigned long long String::asULongLong(const String&str)
{
	for(int i=0; i<str.length(); i++)
	{
		char c = str.charAt(i);
		if(!(c>='0' && c<='9'))
		{
			std::cerr << "Error: invalid String in function String::asULongLong(\"" << str << "\")" << std::endl;
			return 0;
		}
	}
	
	int startIndex = 0;
	
	int counter = 0;
	unsigned long long totalVal = 0;
	
	for(int i=(str.length()-1); i>=startIndex; i--)
	{
		char c = str.charAt(i);
		unsigned int value = (unsigned int)(c - '0');
		if(counter==0)
		{
			totalVal += value;
		}
		else
		{
			totalVal += ((unsigned long long)value*(unsigned long long)string_powull((unsigned long long)10,(int)counter));
		}
		counter++;
	}
	
	return totalVal;
}

std::string String::intToString(const int num) const
{
	std::stringstream ss;
	ss << num;
	std::string s(ss.str());
	return s;
}

std::string String::uintToString(const unsigned int num) const
{
	std::stringstream ss;
	ss << num;
	std::string s(ss.str());
	return s;
}

std::string String::floatToString(const float num) const
{
	/*std::stringstream ss;
	ss.precision(20);
	ss << num;
	std::string s(ss.str());
	return s;*/
	char buffer[20];
	sprintf(buffer, "%g", (double)num);
	return std::string(buffer);
}

std::string String::doubleToString(const double num) const
{
	/*std::stringstream ss;
	ss.precision(20);
	ss << num;
	std::string s(ss.str());
	return s;*/
	char buffer[20];
	sprintf(buffer, "%g", (double)num);
	return std::string(buffer);
}

std::string String::longToString(const long num) const
{
	std::stringstream ss;
	ss << num;
	std::string s(ss.str());
	return s;
}

String::String()
{
	total = 0;
	characters = (char*)calloc(1,1);
	characters[0] = '\0';
}

String::String(const String& str)
{
	total = str.length();
	characters = (char*)calloc(total+1,1);
	for(int i=0; i<total; i++)
	{
		characters[i] = str.characters[i];
	}

	characters[total] = '\0';
}

String::String(const std::string&str)
{
	total = str.length();
	characters = (char*)calloc(total+1,1);
	for(int i=0; i<total; i++)
	{
		characters[i] = str.at(i);
	}

	characters[total] = '\0';
}

String::String(const char*str)
{
	total = strlen(str);
	characters = (char*)calloc(total+1,1);
	for(int i=0; i<total; i++)
	{
		characters[i] = str[i];
	}

	characters[total] = '\0';
}

String::String(const wchar_t*str)
{
	int len = wcslen(str);
	total = len;
	characters = (char*)calloc(total+1,1);

	wcstombs(characters,str,total+1);

	characters[total] = '\0';
}

String::String(const std::wstring&str)
{
	int len = str.length();
	total = len;
	characters = (char*)calloc(total+1,1);

	wcstombs(characters,str.c_str(),total+1);

	characters[total] = '\0';
}

String::String(const char c)
{
	total = 1;
	characters = (char*)calloc(total+1,1);

	characters[0] = c;
	characters[1] = '\0';
}

String::String(const unsigned char num)
{
	std::string str = intToString((int)num);
	total = str.length();
	characters = (char*)calloc(total+1,1);

	for(int i=0; i<total; i++)
	{
		characters[i] = str.at(i);
	}

	characters[total] = '\0';
}

String::String(const bool b)
{
	if(b)
	{
		characters = (char*)calloc(4+1,1);
		characters[0] = 't';
		characters[1] = 'r';
		characters[2] = 'u';
		characters[3] = 'e';
		characters[4] = '\0';
		total = 4;
	}
	else
	{
		characters = (char*)calloc(5+1,1);
		characters[0] = 'f';
		characters[1] = 'a';
		characters[2] = 'l';
		characters[3] = 's';
		characters[4] = 'e';
		characters[5] = '\0';
		total = 5;
	}
}

String::String(const int num)
{
	std::string str = intToString(num);
	total = str.length();
	characters = (char*)calloc(total+1,1);

	for(int i=0; i<total; i++)
	{
		characters[i] = str.at(i);
	}

	characters[total] = '\0';
}

String::String(const unsigned int num)
{
	std::string str = uintToString(num);
	total = str.length();
	characters = (char*)calloc(total+1,1);

	for(int i=0; i<total; i++)
	{
		characters[i] = str.at(i);
	}

	characters[total] = '\0';
}

String::String(const float num)
{
	std::string str = floatToString(num);
	total = str.length();
	characters = (char*)calloc(total+1,1);

	for(int i=0; i<total; i++)
	{
		characters[i] = str.at(i);
	}

	characters[total] = '\0';
}

String::String(const double num)
{
	std::string str = doubleToString(num);
	total = str.length();
	characters = (char*)calloc(total+1,1);

	for(int i=0; i<total; i++)
	{
		characters[i] = str.at(i);
	}

	characters[total] = '\0';
}

String::String(const long num)
{
	std::string str = longToString(num);
	total = str.length();
	characters = (char*)calloc(total+1,1);

	for(int i=0; i<total; i++)
	{
		characters[i] = str.at(i);
	}

	characters[total] = '\0';
}

String::~String()
{
	free(characters);
	characters = NULL;
}

String::operator char*()
{
	return characters;
}

String::operator const char*()
{
	return characters;
}

String::operator std::string()
{
	return std::string(characters);
}

String::operator std::wstring()
{
	wchar_t*str = new wchar_t[total+1];
	mbstowcs(str,characters,total+1);
	std::wstring newStr(str);
	delete[] str;
	return newStr;
}

String::operator char*() const
{
	return characters;
}

String::operator const char*() const
{
	return characters;
}

String::operator std::string() const
{
	return std::string(characters);
}

String::operator std::wstring() const
{
	wchar_t*str = new wchar_t[total+1];
	mbstowcs(str,characters,total+1);
	std::wstring newStr(str);
	delete[] str;
	return newStr;
}

String String::operator+(const String& str) const
{
	String newStr;
	int total2 = total + str.length();
	newStr.characters = (char*)realloc(newStr.characters, total2+1);
	newStr.total = total2;
	for(int i=0; i<total; i++)
	{
		newStr.characters[i] = characters[i];
	}
	int counter = 0;
	for(int i=total; i<total2; i++)
	{
		newStr.characters[i] = str.characters[counter];
		counter++;
	}
	newStr.characters[total2] = '\0';
	return newStr;
}

String String::operator+(const std::string& str) const
{
	String newStr;
	int total2 = total + str.length();
	newStr.characters = (char*)realloc(newStr.characters, total2+1);
	newStr.total = total2;
	for(int i=0; i<total; i++)
	{
		newStr.characters[i] = characters[i];
	}
	int counter = 0;
	for(int i=total; i<total2; i++)
	{
		newStr.characters[i] = str.at(counter);
		counter++;
	}
	newStr.characters[total2] = '\0';
	return newStr;
}

String String::operator+(const char*str) const
{
	String newStr;
	int total2 = total + strlen(str);
	newStr.characters = (char*)realloc(newStr.characters, total2+1);
	newStr.total = total2;
	for(int i=0; i<total; i++)
	{
		newStr.characters[i] = characters[i];
	}
	int counter = 0;
	for(int i=total; i<total2; i++)
	{
		newStr.characters[i] = str[counter];
		counter++;
	}
	newStr.characters[total2] = '\0';
	return newStr;
}

String String::operator+(const wchar_t*str) const
{
	String newStr;
	String str2(str);
	int total2 = total + str2.length();
	newStr.characters = (char*)realloc(newStr.characters, total2+1);
	newStr.total = total2;
	for(int i=0; i<total; i++)
	{
		newStr.characters[i] = characters[i];
	}
	int counter = 0;
	for(int i=total; i<total2; i++)
	{
		newStr.characters[i] = str2.characters[counter];
		counter++;
	}
	newStr.characters[total2] = '\0';
	return newStr;
}

String String::operator+(const std::wstring& str) const
{
	String newStr;
	String str2(str);
	int total2 = total + str2.length();
	newStr.characters = (char*)realloc(newStr.characters, total2+1);
	newStr.total = total2;
	for(int i=0; i<total; i++)
	{
		newStr.characters[i] = characters[i];
	}
	int counter = 0;
	for(int i=total; i<total2; i++)
	{
		newStr.characters[i] = str2.characters[counter];
		counter++;
	}
	newStr.characters[total2] = '\0';
	return newStr;
}

String String::operator+(const bool b) const
{
	String newStr = characters;
	if(b)
	{
		newStr += "true";
	}
	else
	{
		newStr += "false";
	}
	return newStr;
}

String String::operator+(const char c) const
{
	String newStr;
	int total2 = total+1;
	newStr.characters = (char*)realloc(newStr.characters, total2+1);
	newStr.total = total2;
	for(int i=0; i<total; i++)
	{
		newStr.characters[i] = characters[i];
	}
	newStr.characters[total] = c;
	newStr.characters[total+1] = '\0';
	return newStr;
}

String String::operator+(const unsigned char num) const
{
	String newStr;
	std::string str = intToString((int)num);
	int total2 = total + str.length();
	newStr.characters = (char*)realloc(newStr.characters, total2+1);
	newStr.total = total2;
	for(int i=0; i<total; i++)
	{
		newStr.characters[i] = characters[i];
	}
	int counter = 0;
	for(int i=total; i<total2; i++)
	{
		newStr.characters[i] = str.at(counter);
		counter++;
	}
	newStr.characters[total2] = '\0';
	return newStr;
}

String String::operator+(const int num) const
{
	String newStr;
	std::string str = intToString(num);
	int total2 = total + str.length();
	newStr.characters = (char*)realloc(newStr.characters, total2+1);
	newStr.total = total2;
	for(int i=0; i<total; i++)
	{
		newStr.characters[i] = characters[i];
	}
	int counter = 0;
	for(int i=total; i<total2; i++)
	{
		newStr.characters[i] = str.at(counter);
		counter++;
	}
	newStr.characters[total2] = '\0';
	return newStr;
}

String String::operator+(const unsigned int num) const
{
	String newStr;
	std::string str = uintToString(num);
	int total2 = total + str.length();
	newStr.characters = (char*)realloc(newStr.characters, total2+1);
	newStr.total = total2;
	for(int i=0; i<total; i++)
	{
		newStr.characters[i] = characters[i];
	}
	int counter = 0;
	for(int i=total; i<total2; i++)
	{
		newStr.characters[i] = str.at(counter);
		counter++;
	}
	newStr.characters[total2] = '\0';
	return newStr;
}

String String::operator+(const long num) const
{
	String newStr;
	std::string str = longToString(num);
	int total2 = total + str.length();
	newStr.characters = (char*)realloc(newStr.characters, total2+1);
	newStr.total = total2;
	for(int i=0; i<total; i++)
	{
		newStr.characters[i] = characters[i];
	}
	int counter = 0;
	for(int i=total; i<total2; i++)
	{
		newStr.characters[i] = str.at(counter);
		counter++;
	}
	newStr.characters[total2] = '\0';
	return newStr;
}

String String::operator+(const float num) const
{
	String newStr;
	std::string str = floatToString(num);
	int total2 = total + str.length();
	newStr.characters = (char*)realloc(newStr.characters, total2+1);
	newStr.total = total2;
	for(int i=0; i<total; i++)
	{
		newStr.characters[i] = characters[i];
	}
	int counter = 0;
	for(int i=total; i<total2; i++)
	{
		newStr.characters[i] = str.at(counter);
		counter++;
	}
	newStr.characters[total2] = '\0';
	return newStr;
}

String String::operator+(const double num) const
{
	String newStr;
	std::string str = doubleToString(num);
	int total2 = total + str.length();
	newStr.characters = (char*)realloc(newStr.characters, total2+1);
	newStr.total = total2;
	for(int i=0; i<total; i++)
	{
		newStr.characters[i] = characters[i];
	}
	int counter = 0;
	for(int i=total; i<total2; i++)
	{
		newStr.characters[i] = str.at(counter);
		counter++;
	}
	newStr.characters[total2] = '\0';
	return newStr;
}

String& String::operator+=(const String& str)
{
	int total2 = total + str.length();
	characters = (char*)realloc(characters, total2+1);
	int counter = 0;
	for(int i=total; i<total2; i++)
	{
		characters[i] = str.characters[counter];
		counter++;
	}
	total = total2;
	characters[total2] = '\0';
	return *this;
}

String& String::operator+=(const std::string& str)
{
	int total2 = total + str.length();
	characters = (char*)realloc(characters, total2+1);
	int counter = 0;
	for(int i=total; i<total2; i++)
	{
		characters[i] = str.at(counter);
		counter++;
	}
	total = total2;
	characters[total2] = '\0';
	return *this;
}

String& String::operator+=(const char*str)
{
	int total2 = total + strlen(str);
	characters = (char*)realloc(characters, total2+1);
	int counter = 0;
	for(int i=total; i<total2; i++)
	{
		characters[i] = str[counter];
		counter++;
	}
	total = total2;
	characters[total2] = '\0';
	return *this;
}

String& String::operator+=(const wchar_t*str)
{
	String str2(str);
	int total2 = total + str2.length();
	characters = (char*)realloc(characters, total2+1);
	int counter = 0;
	for(int i=total; i<total2; i++)
	{
		characters[i] = str2.characters[counter];
		counter++;
	}
	total = total2;
	characters[total2] = '\0';
	return *this;
}

String& String::operator+=(const std::wstring str)
{
	String str2(str);
	int total2 = total + str2.length();
	characters = (char*)realloc(characters, total2+1);
	int counter = 0;
	for(int i=total; i<total2; i++)
	{
		characters[i] = str2.characters[counter];
		counter++;
	}
	total = total2;
	characters[total2] = '\0';
	return *this;
}

String& String::operator+=(const bool b)
{
	if(b)
	{
		characters = (char*)realloc(characters, total+5);
		characters[total]   = 't';
		characters[total+1] = 'r';
		characters[total+2] = 'u';
		characters[total+3] = 'e';
		characters[total+4] = '\0';
		total += 4;
	}
	else
	{
		characters = (char*)realloc(characters, total+6);
		characters[total]   = 'f';
		characters[total+1] = 'a';
		characters[total+2] = 'l';
		characters[total+3] = 's';
		characters[total+4] = 'e';
		characters[total+5] = '\0';
		total += 5;
	}
	return *this;
}

String& String::operator+=(const char c)
{
	int total2 = total+1;
	characters = (char*)realloc(characters, total2+1);
	characters[total]=c;
	characters[total2]='\0';
	total = total2;
	return *this;
}

String& String::operator+=(const unsigned char num)
{
	std::string str2 = intToString((int)num);
	int total2 = total + str2.length();
	characters = (char*)realloc(characters, total2+1);
	int counter = 0;
	for(int i=total; i<total2; i++)
	{
		characters[i] = str2.at(counter);
		counter++;
	}
	total = total2;
	characters[total2] = '\0';
	return *this;
}

String& String::operator+=(const int num)
{
	std::string str2 = intToString(num);
	int total2 = total + str2.length();
	characters = (char*)realloc(characters, total2+1);
	int counter = 0;
	for(int i=total; i<total2; i++)
	{
		characters[i] = str2.at(counter);
		counter++;
	}
	total = total2;
	characters[total2] = '\0';
	return *this;
}

String& String::operator+=(const unsigned int num)
{
	std::string str2 = uintToString(num);
	int total2 = total + str2.length();
	characters = (char*)realloc(characters, total2+1);
	int counter = 0;
	for(int i=total; i<total2; i++)
	{
		characters[i] = str2.at(counter);
		counter++;
	}
	total = total2;
	characters[total2] = '\0';
	return *this;
}

String& String::operator+=(const long num)
{
	std::string str2 = longToString(num);
	int total2 = total + str2.length();
	characters = (char*)realloc(characters, total2+1);
	int counter = 0;
	for(int i=total; i<total2; i++)
	{
		characters[i] = str2.at(counter);
		counter++;
	}
	total = total2;
	characters[total2] = '\0';
	return *this;
}

String& String::operator+=(const float num)
{
	std::string str2 = floatToString(num);
	int total2 = total + str2.length();
	characters = (char*)realloc(characters, total2+1);
	int counter = 0;
	for(int i=total; i<total2; i++)
	{
		characters[i] = str2.at(counter);
		counter++;
	}
	total = total2;
	characters[total2] = '\0';
	return *this;
}

String& String::operator+=(const double num)
{
	std::string str2 = doubleToString(num);
	int total2 = total + str2.length();
	characters = (char*)realloc(characters, total2+1);
	int counter = 0;
	for(int i=total; i<total2; i++)
	{
		characters[i] = str2.at(counter);
		counter++;
	}
	total = total2;
	characters[total2] = '\0';
	return *this;
}

String& String::operator=(const String& str)
{
	int total2 = str.length();
	characters = (char*)realloc(characters, total2+1);
	total = total2;
	for(int i=0; i<total2; i++)
	{
		characters[i] = str.characters[i];
	}
	characters[total2] = '\0';
	return *this;
}

String& String::operator=(const std::string& str)
{
	int total2 = str.length();
	characters = (char*)realloc(characters, total2+1);
	total = total2;
	for(int i=0; i<total2; i++)
	{
		characters[i] = str.at(i);
	}
	characters[total2] = '\0';
	return *this;
}

String& String::operator=(const char*str)
{
	int total2 = strlen(str);
	characters = (char*)realloc(characters, total2+1);
	total = total2;
	for(int i=0; i<total2; i++)
	{
		characters[i] = str[i];
	}
	characters[total2] = '\0';
	return *this;
}

String& String::operator=(const wchar_t*str)
{
	String str2(str);
	int total2 = str2.length();
	characters = (char*)realloc(characters, total2+1);
	total = total2;
	for(int i=0; i<total2; i++)
	{
		characters[i] = str2.characters[i];
	}
	characters[total2] = '\0';
	return *this;
}

String& String::operator=(const std::wstring& str)
{
	String str2(str);
	int total2 = str2.length();
	characters = (char*)realloc(characters, total2+1);
	total = total2;
	for(int i=0; i<total2; i++)
	{
		characters[i] = str2.characters[i];
	}
	characters[total2] = '\0';
	return *this;
}

String& String::operator=(const bool b)
{
	if(b)
	{
		characters = (char*)realloc(characters, 5);
		characters[0] = 't';
		characters[1] = 'r';
		characters[2] = 'u';
		characters[3] = 'e';
		characters[4] = '\0';
		total = 4;
	}
	else
	{
		characters = (char*)realloc(characters, 6);
		characters[0] = 'f';
		characters[1] = 'a';
		characters[2] = 'l';
		characters[3] = 's';
		characters[4] = 'e';
		characters[5] = '\0';
		total = 5;
	}
	return *this;
}

String& String::operator=(const char c)
{
	int total2 = 1;
	characters = (char*)realloc(characters, total2+1);
	total = total2;
	characters[0] = c;
	characters[1] = '\0';
	return *this;
}

String& String::operator=(const unsigned char num)
{
	std::string str2 = intToString((int)num);
	int total2 = str2.length();
	characters = (char*)realloc(characters, total2+1);
	total = total2;
	for(int i=0; i<total2; i++)
	{
		characters[i] = str2.at(i);
	}
	characters[total2] = '\0';
	return *this;
}

String& String::operator=(const int num)
{
	std::string str2 = intToString(num);
	int total2 = str2.length();
	characters = (char*)realloc(characters, total2+1);
	total = total2;
	for(int i=0; i<total2; i++)
	{
		characters[i] = str2.at(i);
	}
	characters[total2] = '\0';
	return *this;
}

String& String::operator=(const unsigned int num)
{
	std::string str2 = uintToString(num);
	int total2 = str2.length();
	characters = (char*)realloc(characters, total2+1);
	total = total2;
	for(int i=0; i<total2; i++)
	{
		characters[i] = str2.at(i);
	}
	characters[total2] = '\0';
	return *this;
}

String& String::operator=(const long num)
{
	std::string str2 = longToString(num);
	int total2 = str2.length();
	characters = (char*)realloc(characters, total2+1);
	total = total2;
	for(int i=0; i<total2; i++)
	{
		characters[i] = str2.at(i);
	}
	characters[total2] = '\0';
	return *this;
}

String& String::operator=(const float num)
{
	std::string str2 = floatToString(num);
	int total2 = str2.length();
	characters = (char*)realloc(characters, total2+1);
	total = total2;
	for(int i=0; i<total2; i++)
	{
		characters[i] = str2.at(i);
	}
	characters[total2] = '\0';
	return *this;
}

String& String::operator=(const double num)
{
	std::string str2 = doubleToString(num);
	int total2 = str2.length();
	characters = (char*)realloc(characters, total2+1);
	total = total2;
	for(int i=0; i<total2; i++)
	{
		characters[i] = str2.at(i);
	}
	characters[total2] = '\0';
	return *this;
}

bool String::operator==(String& cmp)
{
	return equals(cmp);
}

bool String::operator==(const char*cmp)
{
	return equals(cmp);
}

std::ostream& operator<<(std::ostream& stream, const String& str)
{
	return stream << str.characters << "";
}

bool String::equals(const String& cmp) const
{
	if(cmp.length()==length())
	{
		for(int i=(total-1); i>=0; i--)
		{
			if((int)characters[i] != (int)cmp.characters[i])
			{
				return false;
			}
		}
		return true;
	}
	return false;
}

bool String::equals(const char*cmp) const
{
	if(cmp!=NULL)
	{
		int cmpLength = strlen(cmp);
		if(cmpLength==length())
		{
			for(int i=0; i<total; i++)
			{
				if(characters[i] != cmp[i])
				{
					return false;
				}
			}
			return true;
		}
		return false;
	}
	return false;
}

static unsigned char STRINGCMP_CHARTYPE_SYMBOL = 0;
static unsigned char STRINGCMP_CHARTYPE_ZERO = 1;
static unsigned char STRINGCMP_CHARTYPE_NUMBER = 2;
static unsigned char STRINGCMP_CHARTYPE_UPPERCASE_LETTER = 3;
static unsigned char STRINGCMP_CHARTYPE_LOWERCASE_LETTER = 4;

unsigned char StringCmp_getCharType(const char&c)
{
	if(c=='0')
	{
		return STRINGCMP_CHARTYPE_ZERO;
	}
	else if(c>='1' && c<='9')
	{
		return STRINGCMP_CHARTYPE_NUMBER;
	}
	else if(c>='A' && c<='Z')
	{
		return STRINGCMP_CHARTYPE_UPPERCASE_LETTER;
	}
	else if(c>='a' && c<='z')
	{
		return STRINGCMP_CHARTYPE_LOWERCASE_LETTER;
	}
	return STRINGCMP_CHARTYPE_SYMBOL;
}

int String::compare(const String&cmp) const
{
	int amount = 0;
	if(cmp.length()>total)
	{
		amount = total;
	}
	else
	{
		amount = cmp.length();
	}
	
	bool hasCap1 = false;
	bool hasCap2 = false;
	
	for(int i=0; i<amount; i++)
	{
		char c1 = characters[i];
		char c2 = cmp.characters[i];
		
		unsigned char type1 = StringCmp_getCharType(c1);
		unsigned char type2 = StringCmp_getCharType(c2);
		
		if(type1==type2)
		{
			if(c1<c2)
			{
				return 1;
			}
			else if(c2<c1)
			{
				return -1;
			}
		}
		else
		{
			if(type1==STRINGCMP_CHARTYPE_UPPERCASE_LETTER && type2==STRINGCMP_CHARTYPE_LOWERCASE_LETTER)
			{
				char c1mod = c1 - 'A';
				char c2mod = c2 - 'a';
				
				if(c1mod<c2mod)
				{
					return 1;
				}
				else if(c2mod<c1mod)
				{
					return -1;
				}
				else
				{
					if(!hasCap1 && !hasCap2)
					{
						hasCap1 = true;
					}
				}
			}
			else if(type1==STRINGCMP_CHARTYPE_LOWERCASE_LETTER && type2==STRINGCMP_CHARTYPE_UPPERCASE_LETTER)
			{
				char c1mod = c1 - 'a';
				char c2mod = c2 - 'A';
				
				if(c1mod<c2mod)
				{
					return 1;
				}
				else if(c2mod<c1mod)
				{
					return -1;
				}
				else
				{
					if(!hasCap1 && !hasCap2)
					{
						hasCap2 = true;
					}
				}
			}
			else
			{
				if(type1<type2)
				{
					return 1;
				}
				else if(type2<type1)
				{
					return -1;
				}
			}
		}
	}
	
	if(total < cmp.length())
	{
		return 1;
	}
	else if(cmp.length() < total)
	{
		return -1;
	}
	else
	{
		if(hasCap1)
		{
			return 1;
		}
		else if(hasCap2)
		{
			return -1;
		}
		return 0;
	}
}

void String::clear()
{
	characters = (char*)realloc(characters, 1);
	characters[0] = '\0';
	total = 0;
}

int String::length() const
{
	return total;
}

char String::charAt(int index) const
{
	return characters[index];
}

void String::replace(const String&find, const String&rep)
{
	if(find.total==0)
	{
		return;
	}
	
	std::vector<int> indexes;
	int indexTotal = 0;
	
	int finish = total - find.total;
	
	for(int i=0; i<=finish; i++)
	{
		if(characters[i]==find.characters[0])
		{
			bool match = true;
			for(int j=1; j<find.total; j++)
			{
				if(characters[i+j] != find.characters[j])
				{
					match = false;
					j = find.total;
				}
			}
			
			if(match)
			{
				indexes.resize(indexTotal+1);
				indexes[indexTotal] = i;
				indexTotal++;
				i+= (find.total-1);
			}
		}
	}
	
	if(indexes.size()>0)
	{
		int dif = (rep.length() - find.length());
		int totalSize = total + (indexes.size()*dif);
		
		if(rep.total>find.total)
		{
			characters = (char*)realloc(characters, totalSize+1);
			characters[totalSize] = '\0';
			
			int counterNew = totalSize;
			int counterOld = total;
			int lastIndex = total;
			for(int i=(indexes.size()-1); i>=0; i--)
			{
				int offset = lastIndex - (indexes[i]+find.total) + 1;
				lastIndex = indexes[i];
				for(int j=0; j<offset; j++)
				{
					characters[counterNew] = characters[counterOld];
					counterNew--;
					counterOld--;
				}
				counterNew-=(rep.total-1);
				counterOld-=(find.total-1);
				if(i==0 && counterOld!=0)
				{
					while(counterOld>=0)
					{
						characters[counterNew] = characters[counterOld];
						counterNew--;
						counterOld--;
					}
				}
			}
			
			total = totalSize;
		}
		else if(rep.total<find.total)
		{
			int counterNew = 0;
			int counterOld = 0;
			int lastIndex = 0;
			for(int i=0; i<indexes.size(); i++)
			{
				int offset = indexes[i] - lastIndex;
				lastIndex = indexes[i] + find.total;
				for(int j=0; j<offset; j++)
				{
					characters[counterNew] = characters[counterOld];
					counterNew++;
					counterOld++;
				}
				counterNew += rep.total;
				counterOld += find.total;
				if(i==(indexes.size()-1) && counterOld<total)
				{
					while(counterOld<total)
					{
						characters[counterNew] = characters[counterOld];
						counterNew++;
						counterOld++;
					}
				}
			}
			
			characters = (char*)realloc(characters, totalSize+1);
			characters[totalSize] = '\0';
			total = totalSize;
		}
		
		int difCounter = 0;
		for(int i=0; i<indexes.size(); i++)
		{
			int offset = indexes[i] + difCounter;
			for(int j=0; j<rep.total; j++)
			{
				characters[offset+j] = rep.characters[j];
			}
			difCounter+=dif;
		}
	}
}

String String::substring(int beginIndex) const
{
	String str;
	str.characters = (char*)realloc(str.characters, (total-beginIndex)+1);
	int counter = 0;
	for(int i=beginIndex; i<total; i++)
	{
		str.characters[counter] = characters[i];
		counter++;
	}
	str.characters[counter] = '\0';
	str.total = counter;
	return str;
}

String String::substring(int beginIndex, int endIndex) const
{
	String str;
	str.characters = (char*)realloc(str.characters, (endIndex-beginIndex)+1);
	int counter = 0;
	for(int i=beginIndex; i<endIndex; i++)
	{
		str.characters[counter] = characters[i];
		counter++;
	}
	str.characters[counter] = '\0';
	str.total = counter;
	return str;
}

String String::trim() const
{
	int i=0;
	
	int startIndex = 0;
	
	bool hitLetter = false;
	
	while(!hitLetter && i<total)
	{
		char c = charAt(i);
		
		if(c>' ')
		{
			startIndex = i;
			hitLetter = true;
		}
		
		i++;
	}
	
	if(!hitLetter)
	{
		return String("");
	}
	
	hitLetter = false;
	i = total-1;

	int endIndex = 0;
	
	while(!hitLetter && i>=0)
	{
		char c = charAt(i);

		if(c>' ')
		{
			endIndex = i+1;
			hitLetter = true;
		}

		i--;
	}

	return substring(startIndex, endIndex);
}

int String::indexOf(const String&str) const
{
	if(str.total==0)
	{
		return -1;
	}
	
	int finish = total - str.total;
	
	for(int i=0; i<=finish; i++)
	{
		if(characters[i]==str.characters[0])
		{
			bool match = true;
			for(int j=1; j<str.total; j++)
			{
				if(characters[i+j] != str.characters[j])
				{
					match = false;
					j = str.total;
				}
			}
			
			if(match)
			{
				return i;
			}
		}
	}
	return -1;
	
	/*int length = str.length();
	if(str.length()>0 && total >= length)
	{
		std::vector<int> indexes = std::vector<int>();
		int indexTotal = 0;

		char c = str.charAt(0);

		for(int i=0; i<total; i++)
		{
			if((int)characters[i]==(int)c)
			{
				indexTotal++;
				indexes.resize(indexTotal);
				indexes[indexTotal-1] = i;
			}
		}

		if(indexTotal>0)
		{
			int endOfThis = total - 1;
			for(int i=0; i<indexTotal; i++)
			{
				int end = indexes[i] + length;
				if(end>endOfThis)
				{
					return -1;
				}
				else
				{
					bool correct = true;
					int counter = 0;
					for(int j=indexes[i]; j<end; j++)
					{
						if((int)characters[j]==(int)str.characters[counter])
						{
							counter++;
						}
						else
						{
							correct = false;
							j = end;
						}
					}

					if(correct)
					{
						return indexes[i];
					}
				}
			}
		}
		return -1;
	}
	return -1;*/
}

int String::lastIndexOf(const String&str) const
{
	if(str.total==0)
	{
		return -1;
	}
	
	int finish = (str.total-1);
	
	for(int i=(total-1); i>=finish; i--)
	{
		if(characters[i]==str.characters[str.total-1])
		{
			bool match = true;
			for(int j=1; j<str.total; j++)
			{
				if(characters[i-j] != str.characters[(str.total-1)-j])
				{
					match = false;
					j = str.total;
				}
			}
			
			if(match)
			{
				return (i-(str.total-1));
			}
		}
	}
	return -1;
}

String String::toLowerCase()
{
	char* str = new char[total+1];
	str[total]='\0';
	
	for(int i=0; i<total; i++)
	{
		char c = characters[i];
		if(c>='A' && c<='Z')
		{
			c = (char)((((int)c)-((int)'A'))+((int)'a'));
		}
		str[i] = c;
	}
	
	String lowercase(str);
	delete str;
	return lowercase;
}

String String::toUpperCase()
{
	char* str = new char[total+1];
	str[total]='\0';
	
	for(int i=0; i<total; i++)
	{
		char c = characters[i];
		if(c>='a' && c<='z')
		{
			c = (char)((((int)c)-((int)'a'))+((int)'A'));
		}
		str[i] = c;
	}
	
	String lowercase(str);
	delete str;
	return lowercase;
}

