local module = {}

local wedge = Instance.new("WedgePart");
wedge.Anchored = true;
wedge.TopSurface = Enum.SurfaceType.Smooth;
wedge.BottomSurface = Enum.SurfaceType.Smooth;



--Triangle function by EgoMoose
function draw3dTriangle(a, b, c, parent, w1, w2)
	
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
	
	w2 = wedge:Clone();
	w2.Size = Vector3.new(0, height, math.abs(ac:Dot(back)));
	w2.CFrame = CFrame.fromMatrix((a + c)/2, -right, up, -back);

	w2.Parent = parent;
	w1.Parent = parent;
	
	return w1, w2;
end

--Fills the quadrant made by four vertices with triangles
function module.fillQuadrant(vert1, vert2, vert3, vert4)
	local model = Instance.new("Model")
	model.Name = "Face"

	local t1, t2 = draw3dTriangle(vert1, vert2, vert3, model)
	local t3, t4 = draw3dTriangle(vert1, vert3, vert4, model)

	t1.Name = "Triangle1"
	t2.Name = "Triangle2"
	t3.Name = "Triangle3"
	t4.Name = "Triangle4"

	local color = BrickColor.random()

	t1.BrickColor = color
	t2.BrickColor = color
	t3.BrickColor = color
	t4.BrickColor = color

	return model
end

return module