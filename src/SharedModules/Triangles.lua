local module = {}
--[[function module.createTriangle(a, b, c)
	local parent = workspace
	local thickness = 0.01
	local v3 = Vector3.new
	local cf = CFrame.new
	local abs = math.abs
	local cross = v3().Cross
	local dot = v3().Dot
	local clone = game.Clone
	
	local ref = Instance.new('WedgePart') do
		ref.Color         = Color3.fromRGB(200, 200, 200)
		ref.Material      = Enum.Material.SmoothPlastic
		ref.Reflectance   = 0
		ref.Transparency  = 0
		ref.Name          = ''
		ref.Anchored      = true
		ref.CanCollide    = true
		ref.CFrame        = cf()
		ref.Size          = v3(1, 1, 1)
		ref.BottomSurface = Enum.SurfaceType.Smooth
		ref.TopSurface    = Enum.SurfaceType.Smooth
	end
	
	local function fromAxes(p, x, y, z)
		return cf(
			p.x, p.y, p.z,
			x.x, y.x, z.x,
			x.y, y.y, z.y,
			x.z, y.z, z.z
		)
	end
	
	
	local ab, ac, bc = b - a, c - a, c - b
	local abl, acl, bcl = ab.magnitude, ac.magnitude, bc.magnitude
	if abl > bcl and abl > acl then
		c, a = a, c
	elseif acl > bcl and acl > abl then
		a, b = b, a
	end
	ab, ac, bc = b - a, c - a, c - b
	local out = cross(ac, ab).unit
	local wb = clone(ref)
	local wc = clone(ref)
	local biDir = cross(bc, out).unit
	local biLen = abs(dot(ab, biDir))
	local norm = bc.magnitude
	wb.Size = v3(thickness, abs(dot(ab, bc))/norm, biLen)
	wc.Size = v3(thickness, biLen, abs(dot(ac, bc))/norm)
	bc = -bc.unit
	wb.CFrame = fromAxes((a + b)/2, -out, bc, -biDir)
	wc.CFrame = fromAxes((a + c)/2, -out, biDir, bc)
	
	wb.Size = Vector3.new(wb.Size.X * 2, wb.Size.Y, wb.Size.Z)
	wc.Size = Vector3.new(wc.Size.X * 2, wc.Size.Y, wc.Size.Z)
	
	wb.Parent = parent
	wc.Parent = parent
	return wb, wc
end]]

local wedge = Instance.new("WedgePart");
wedge.Anchored = true;
wedge.TopSurface = Enum.SurfaceType.Smooth;
wedge.BottomSurface = Enum.SurfaceType.Smooth;



--Triangle function by EgoMoose
local function draw3dTriangle(a, b, c, parent, w1, w2)
	
	local ab, ac, bc = b - a, c - a, c - b;
	local abd, acd, bcd = ab:Dot(ab), ac:Dot(ac), bc:Dot(bc);
	
	if (abd > acd and abd > bcd) then
		c, a = a, c;
	elseif (acd > bcd and acd > abd) then
		a, b = b, a;
	end
	
	ab, ac, bc = b - a, c - a, c - b;
	
	local right = ac:Cross(ab).unit;
	local up = bc:Cross(right).unit;
	local back = bc.unit;
	
	local height = math.abs(ab:Dot(up));
	
	w1 = wedge:Clone();
	w1.Size = Vector3.new(0, height, math.abs(ab:Dot(back)));
	w1.CFrame = CFrame.fromMatrix((a + b)/2, right, up, back);
	w1.Parent = parent;
	
	w2 = wedge:Clone();
	w2.Size = Vector3.new(0, height, math.abs(ac:Dot(back)));
	w2.CFrame = CFrame.fromMatrix((a + c)/2, -right, up, -back);
	w2.Parent = parent;
	
	return w1, w2;
end

--Fills the quadrant made by four vertices with triangles
function module.fillQuadrant(quadrantVerts)
	local vert1 = quadrantVerts[1]
	local vert2 = quadrantVerts[2]
	local vert3 = quadrantVerts[3]
	local vert4 = quadrantVerts[4]

	local model = Instance.new("Model")
	model.Name = "Face"

	local t1, t2 = draw3dTriangle(vert1, vert2, vert3, model)
	local t3, t4 = draw3dTriangle(vert1, vert3, vert4, model)

	t1.Name = "Triangle1"
	t2.Name = "Triangle2"
	t3.Name = "Triangle3"
	t4.Name = "Triangle4"

	t1.Anchored = true
	t2.Anchored = true
	t3.Anchored = true
	t4.Anchored = true

	local color = BrickColor.random()

	t1.BrickColor = color
	t2.BrickColor = color
	t3.BrickColor = color
	t4.BrickColor = color

	return model
end

return module