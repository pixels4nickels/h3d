package h3d;

class Quat {
	
	public var x : Float;
	public var y : Float;
	public var z : Float;
	public var w : Float;
	
	public inline function new( x = 0., y = 0., z = 0., w = 1. ) {
		this.x = x;
		this.y = y;
		this.z = z;
		this.w = w;
	}
	
	public inline function set(x, y, z, w) {
		this.x = x;
		this.y = y;
		this.z = z;
		this.w = w;
	}
	
	public inline function identity() {
		x = y = z = 0;
		w = 1;
	}
	
	public function length() {
		return FMath.sqrt(x * x + y * y + z * z + w * w);
	}
	
	public function clone() {
		return new Quat(x, y, z, w);
	}
	
	public function initRotateAxis( x : Float, y : Float, z : Float, a : Float ) {
		var sin = FMath.sin(a / 2);
		var cos = FMath.cos(a / 2);
		this.x = x * sin;
		this.y = y * sin;
		this.z = z * sin;
		this.w = cos * FMath.sqrt(x * x + y * y + z * z); // allow not normalized axis
		normalize();
	}
	
	public function initRotateMatrix( m : Matrix ) {
		var tr = m._11 + m._22 + m._33;
		if( tr > 0 ) {
			var s = FMath.sqrt(tr + 1.0) * 2;
			var is = 1 / s;
			x = (m._23 - m._32) * is;
			y = (m._31 - m._13) * is;
			z = (m._12 - m._21) * is;
			w = 0.25 * s;
		} else if( m._11 > m._22 && m._11 > m._33 ) {
			var s = FMath.sqrt(1.0 + m._11 - m._22 - m._33) * 2;
			var is = 1 / s;
			x = 0.25 * s;
			y = (m._21 + m._12) * is;
			z = (m._31 + m._13) * is;
			w = (m._23 - m._32) * is;
		} else if( m._22 > m._33 ) {
			var s = FMath.sqrt(1.0 + m._22 - m._11 - m._33) * 2;
			var is = 1 / s;
			x = (m._21 + m._12) * is;
			y = 0.25 * s;
			z = (m._32 + m._23) * is;
			w = (m._31 - m._13) * is;
		} else {
			var s = FMath.sqrt(1.0 + m._33 - m._11 - m._22) * 2;
			var is = 1 / s;
			x = (m._31 + m._13) * is;
			y = (m._32 + m._23) * is;
			z = 0.25 * s;
			w = (m._12 - m._21) * is;
		}
	}
	
	public function normalize() {
		var len = x * x + y * y + z * z + w * w;
		if( len < FMath.EPSILON ) {
			x = y = z = 0;
			w = 1;
		} else {
			var m = FMath.isqrt(len);
			x *= m;
			y *= m;
			z *= m;
			w *= m;
		}
	}
	
	public function initRotate( ax : Float, ay : Float, az : Float ) {
		var sinX = FMath.sin( ax * 0.5 );
		var cosX = FMath.cos( ax * 0.5 );
		var sinY = FMath.sin( ay * 0.5 );
		var cosY = FMath.cos( ay * 0.5 );
		var sinZ = FMath.sin( az * 0.5 );
		var cosZ = FMath.cos( az * 0.5 );
		var cosYZ = cosY * cosZ;
		var sinYZ = sinY * sinZ;
		x = sinX * cosYZ - cosX * sinYZ;
		y = cosX * sinY * cosZ + sinX * cosY * sinZ;
		z = cosX * cosY * sinZ - sinX * sinY * cosZ;
		w = cosX * cosYZ + sinX * sinYZ;
	}
	
	public function multiply( q : Quat ) {
		var x2 = x * q.w + w * q.x + y * q.z - z * q.y;
		var y2 = w * q.y - x * q.z + y * q.w + z * q.x;
		var z2 = w * q.z + x * q.y - y * q.x + z * q.w;
		var w2 = w * q.w - x * q.x - y * q.y - z * q.z;
		x = x2;
		y = y2;
		z = z2;
		w = w2;
	}
	
	public function toMatrix() {
		var m = new Matrix();
		saveToMatrix(m);
		return m;
	}
	
	public function toEuler() {
		return new Vector(
			FMath.atan2(2 * (y * w + x * z), 1 - 2 * (y * y + z * z)),
			Math.asin(2 * (x * y + z * w)),
			FMath.atan2(2 * (x * w - y * z), 1 - 2 * (x * x + z * z))
		);
	}
	
	public inline function lerp( q1 : Quat, q2 : Quat, v : Float ) {
		var x = q1.x * v + q2.x * (1 - v);
		var y = q1.y * v + q2.y * (1 - v);
		var z = q1.z * v + q2.z * (1 - v);
		var w = q1.w * v + q2.w * (1 - v);
		this.x = x;
		this.y = y;
		this.z = z;
		this.w = w;
	}

	public function slerp( q1 : Quat, q2 : Quat, v : Float ) {
		var cosHalfTheta = q1.dot(q2);
		if( FMath.abs(cosHalfTheta) >= 1 ) {
			this.x = q1.x;
			this.y = q1.y;
			this.z = q1.z;
			this.w = q1.w;
			return;
		}
		var halfTheta = Math.acos(cosHalfTheta);
		var invSinHalfTheta = FMath.isqrt(1 - cosHalfTheta * cosHalfTheta);
		if( FMath.abs(invSinHalfTheta) > 1e3 ) {
			this.lerp(q1, q2, 0.5);
			return;
		}
		var a = Math.sin((1 - v) * halfTheta) * invSinHalfTheta;
		var b = Math.sin(v * halfTheta) * invSinHalfTheta;
		this.x = q1.x * a + q2.x * b;
		this.y = q1.y * a + q2.y * b;
		this.z = q1.z * a + q2.z * b;
		this.w = q1.w * a + q2.w * b;
	}
	
	public inline function conjugate() {
		x *= -1;
		y *= -1;
		z *= -1;
	}
	
	/**
		Negate the quaternion: this will not change the actual angle, use `conjugate` for that.
	**/
	public inline function negate() {
		x *= -1;
		y *= -1;
		z *= -1;
		w *= -1;
	}
	
	public inline function dot( q : Quat ) {
		return x * q.x + y * q.y + z * q.z + w * q.w;
	}
	
	/**
		Save to a Left-Handed matrix
	**/
	public function saveToMatrix( m : h3d.Matrix ) {
		var xx = x * x;
		var xy = x * y;
		var xz = x * z;
		var xw = x * w;
		var yy = y * y;
		var yz = y * z;
		var yw = y * w;
		var zz = z * z;
		var zw = z * w;
		m._11 = 1 - 2 * ( yy + zz );
		m._12 = 2 * ( xy + zw );
		m._13 = 2 * ( xz - yw );
		m._14 = 0;
		m._21 = 2 * ( xy - zw );
		m._22 = 1 - 2 * ( xx + zz );
		m._23 = 2 * ( yz + xw );
		m._24 = 0;
		m._31 = 2 * ( xz + yw );
		m._32 = 2 * ( yz - xw );
		m._33 = 1 - 2 * ( xx + yy );
		m._34 = 0;
		m._41 = 0;
		m._42 = 0;
		m._43 = 0;
		m._44 = 1;
		return m;
	}
	
	public function toString() {
		return "{"+FMath.fmt(x)+","+FMath.fmt(y)+","+FMath.fmt(z)+","+FMath.fmt(w)+"}";
	}
	
}
