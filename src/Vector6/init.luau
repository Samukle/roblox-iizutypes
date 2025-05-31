-- TODO@FEATURE Vector6:ToObjectSpace() / Vector6:ToWorldSpace()

local Vector6 = { }
local schema = { }
local shadow = { __index = schema, __type = 'Vector6' }

local shared = require(script.Parent._shared)
local ERR_NOT_WANTED_TYPE = shared.ERR_NOT_WANTED_TYPE
local ERR_READ_ONLY = shared.ERR_READ_ONLY

local TYPE_VECTOR3 = 'Vector3'
local TYPE_VECTOR6 = 'Vector6'
local TYPE_NUMBER = 'number'
local TYPE_TABLE = 'table'
local COMP0, COMP1, COMP2,
      COMP3, COMP4, COMP5 =
      'X', 'Y', 'Z',
      'W', 'H', 'D'

do -- Body

      -- Creates a Vector6 where V = (X, Y, Z, W, H, D)
      function Vector6.new (
            x: number|Vector3|Vector6?, y: number|Vector3?, z: number?,
            w: number?, h: number?,d: number?
      ) : Vector6
            if Vector6.Is(x) then
                  d = x [COMP5]
                  h = x [COMP4]
                  w = x [COMP3]
                  z = x [COMP2]
                  y = x [COMP1]
                  x = x [COMP0]
            end
            if typeof(x) == TYPE_VECTOR3 and typeof(y) == TYPE_VECTOR3 then
                  return Vector6.fromVector3(x, y)
            end

            local vars = { x,y,z, w,h,d }
            for _, var in vars do
                  assert(typeof(var) == TYPE_NUMBER or var == nil, string.format(ERR_NOT_WANTED_TYPE, TYPE_NUMBER, typeof(var)))
            end
            vars = nil
            local this = {
                  [COMP0] = x or 0, [COMP3] = w or 0,
                  [COMP1] = y or 0, [COMP4] = h or 0,
                  [COMP2] = z or 0, [COMP5] = d or 0
            }

            setmetatable(this, shadow)
            return this
      end

      -- Creates a Vector6 based out of two Vector3.
      function Vector6.fromVector3 ( x: Vector3, y: Vector3 ): Vector6
            return Vector6.new(x.X, x.Y, x.Z, y.X, y.Y, y.Z)
      end

      
      -- Returns the Magnitude component of the Vector6 `x`
      function Vector6.GetMagnitude ( x: Vector6 ) : number
            assert(Vector6.Is(x), string.format(ERR_NOT_WANTED_TYPE, TYPE_VECTOR6, typeof(x)))
            return ((x.X)^2 + (x.Y)^2 + (x.Z)^2 + (x.W)^2 + (x.H)^2 + (x.D)^2)^0.5
      end

      -- Returns the Unit component of the Vector6 `x`
      function Vector6.GetUnit ( x: Vector6 ) : Vector6
            assert(Vector6.Is(x), string.format(ERR_NOT_WANTED_TYPE, TYPE_VECTOR6, typeof(x)))
            return x / ((x.X)^2 + (x.Y)^2 + (x.Z)^2 + (x.W)^2 + (x.H)^2 + (x.D)^2)^0.5
      end


      -- Returns two Vector3 with the XYZ and WHD components
      function Vector6.ToVector3 ( x: Vector6 ) : ( Vector3, Vector3 )
            assert(Vector6.Is(x), string.format(ERR_NOT_WANTED_TYPE, TYPE_VECTOR6, typeof(x)))
            return x:ToVector3XYZ(), x:ToVector3WHD()
      end


      -- Returns a Ray with the XYZ and WHD components
      function Vector6.ToRay ( x: Vector6 ) : Ray
            assert(Vector6.Is(x), string.format(ERR_NOT_WANTED_TYPE, TYPE_VECTOR6, typeof(x)))
            return Ray.new(x:ToVector3())
      end
      
      -- Casts a ray with the XYZ and WHD components, with an optional `dataModel` option
      function Vector6.RayCast ( self: Vector6, params: RaycastParams, dataModel: DataModel? ) : RaycastResult
            assert(Vector6.Is(self), string.format(ERR_NOT_WANTED_TYPE, TYPE_VECTOR6, typeof(self)))
            return (dataModel or workspace):Raycast(self:ToVector3(), params)
      end

end

do -- Schema

      function schema.GetComponents( self: Vector6 ): (number, number, number, number, number, number)
            return rawget(self, COMP0), rawget(self, COMP1), rawget(self, COMP2),
                  rawget(self, COMP3), rawget(self, COMP4), rawget(self, COMP5)
      end

     schema.ToVector3 = Vector6.ToVector3
     schema.ToRay = Vector6.ToRay

      function schema.ToVector3XYZ( self: Vector6 ): Vector3
            return Vector3.new(self.X, self.Y, self.Z)
      end

      function schema.ToVector3WHD( self: Vector6 ): Vector3
            return Vector3.new(self.W, self.H, self.D)
      end

      function schema.Lerp ( x: Vector6, y: Vector6, a: number ): Vector6
            assert(Vector6.Is(x), string.format(ERR_NOT_WANTED_TYPE, TYPE_VECTOR6, typeof(x)))
            local v6 = Vector6.new(x)
            for i, j in v6:GetComponents() do
                  v6[i] = j + (y[i] - j) * a
            end
            return v6
      end

      schema.RayCast = Vector6.RayCast

end

do -- Shadow set-up

      function shadow.__index ( self: Vector6, var: string ): any
            if var == "Unit" then
                  return Vector6.GetUnit(self)
            elseif var == "Magnitude" then
                  return Vector6.GetMagnitude(self)
                  
            elseif var == "UnitXYZ" then
                  return self:ToVector3XYZ().Unit
            elseif var == "MagnitudeXYZ" then
                  return self:ToVector3XYZ().Magnitude
                  
            elseif var == "UnitWHD" then
                  return self:ToVector3WHD().Unit
            elseif var == "MagnitudeWHD" then
                  return self:ToVector3WHD().Magnitude

            end
      end

      function shadow.__newindex ( _: Vector6, var: string, val: any ): ( )
            return error(string.format(ERR_READ_ONLY, var, val))
      end

      function shadow.__unm( self: Vector6 ): Vector6
            return Vector6.new ( -self.X, -self.Y, -self.Z, -self.W, -self.H, -self.D )
      end

      function shadow.__add( self: Vector6, val: Vector3|Vector6 ): Vector6
            if Vector6.Is(val) then
                  return Vector6.new ( self.X+val.X, self.Y+val.Y, self.Z+val.Z, self.W+val.W, self.H+val.H, self.D+val.D )
            end
      end
      
      function shadow.__sub( self: Vector6, val: Vector3|Vector6 ): Vector6
            if Vector6.Is(val) then
                  return Vector6.new ( self.X-val.X, self.Y-val.Y, self.Z-val.Z, self.W-val.W, self.H-val.H, self.D-val.D )
            end
      end

      function shadow.__mul( self: Vector6, val: number|Vector3|Vector6 ): Vector6
            if typeof(val) == TYPE_NUMBER then
                  return Vector6.new ( self.X*val, self.Y*val, self.Z*val, self.W*val, self.H*val, self.D*val )
            elseif typeof(val) == TYPE_VECTOR3 then
                  return Vector6.new ( self.X*val.X, self.Y*val.Y, self.Z*val.Z, self.W*val.X, self.H*val.Y, self.D*val.Z )
            elseif Vector6.Is(val) then
                  return Vector6.new ( self.X*val.X, self.Y*val.Y, self.Z*val.Z, self.W*val.W, self.H*val.H, self.D*val.D )
            end
      end

      function shadow.__div( self: Vector6, val: number|Vector3|Vector6 ): Vector6
            if typeof(val) == TYPE_NUMBER then
                  return Vector6.new ( self.X/val, self.Y/val, self.Z/val, self.W/val, self.H/val, self.D/val )
            elseif typeof(val) == TYPE_VECTOR3 then
                  return Vector6.new ( self.X/val.X, self.Y/val.Y, self.Z/val.Z, self.W/val.X, self.H/val.Y, self.D/val.Z )
            elseif Vector6.Is(val) then
                  return Vector6.new ( self.X/val.X, self.Y/val.Y, self.Z/val.Z, self.W/val.W, self.H/val.H, self.D/val.D )
            end
      end

      function shadow.__idiv( self: Vector6, val: number|Vector3|Vector6 ): Vector6
            if typeof(val) == TYPE_NUMBER then
                  return Vector6.new ( self.X//val, self.Y//val, self.Z//val, self.W//val, self.H//val, self.D//val )
            elseif typeof(val) == TYPE_VECTOR3 then
                  return Vector6.new ( self.X//val.X, self.Y//val.Y, self.Z//val.Z, self.W//val.X, self.H//val.Y, self.D//val.Z )
            elseif Vector6.Is(val) then
                  return Vector6.new ( self.X//val.X, self.Y//val.Y, self.Z//val.Z, self.W//val.W, self.H//val.H, self.D//val.D )
            end
      end

      function shadow.__pow( self: Vector6, val: number|Vector3|Vector6 ): Vector6
            if typeof(val) == TYPE_NUMBER then
                  return Vector6.new ( self.X^val, self.Y^val, self.Z^val, self.W^val, self.H^val, self.D^val )
            elseif typeof(val) == TYPE_VECTOR3 then
                  return Vector6.new ( self.X^val.X, self.Y^val.Y, self.Z^val.Z, self.W^val.X, self.H^val.Y, self.D^val.Z )
            elseif Vector6.Is(val) then
                  return Vector6.new ( self.X^val.X, self.Y^val.Y, self.Z^val.Z, self.W^val.W, self.H^val.H, self.D^val.D )
            end
      end

end

Vector6.zero = Vector6.new( 0,0,0, 0,0,0 )
Vector6.one  = Vector6.new( 1,1,1, 1,1,1 )

export type Vector6 = {
      X: number, W: number,
      Y: number, H: number,
      Z: number, D: number,

      Unit: Vector6,
      UnitXYZ: Vector3,
      UnitWHD: Vector3,
      Magnitude: number,
      MagnitudeXYZ: number,
      MagnitudeWHD: number,

      ToVector3: ( self: Vector6 ) -> ( Vector3, Vector3 ),
      ToVector3XYZ: ( self: Vector6 ) -> ( Vector3 ),
      ToVector3WHD: ( self: Vector6 ) -> ( Vector3 ),
      ToRay: ( self: Vector6 ) -> Ray,
      Lerp: ( x: Vector6, y: Vector6, a: number ) -> Vector6,
      RayCast: ( self: Vector6, params: RaycastParams, dataModel: DataModel? ) -> RaycastResult
}

require(script.Parent).new { name = 'Vector6', class = Vector6, schema = schema, shadow = shadow }
return Vector6