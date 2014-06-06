
#pragma once

template <typename T>
class Vector2
{
public:
	T x,y;
	
	Vector2() : x(), y()
	{
		//
	}
	
	Vector2(T X, T Y)
	{
		x = X;
		y = Y;
	}
	
	Vector2(const Vector2<T>&vect)
	{
		x = vect.x;
		y = vect.y;
	}
	
	void operator=(const Vector2<T>&vect)
	{
		x = vect.x;
		y = vect.y;
	}
	
	Vector2<T> operator+(const Vector2<T>&vect)
	{
		return Vector2<T>(x+vect.x, y+vect.y);
	}
	
	Vector2<T> operator-(const Vector2<T>&vect)
	{
		return Vector2<T>(x-vect.x, y-vect.y);
	}
	
	Vector2<T>&operator+=(const Vector2<T>&vect)
	{
		x += vect.x;
		y += vect.y;
		return *this;
	}
	
	Vector2<T>&operator-=(const Vector2<T>&vect)
	{
		x -= vect.x;
		y -= vect.y;
		return *this;
	}
};

typedef Vector2<int> Vector2i;
typedef Vector2<float> Vector2f;
typedef Vector2<double> Vector2d;
typedef Vector2<unsigned int> Vector2u;