let heightMap, colorMap, finalScreen
let shadowShader

function preload() {
	shadowShader = loadShader("/web_shaders/vert_shader.glsl", "/web_shaders/frag_shader.glsl")
}

function setup() {
	createCanvas(2048, 2048)
	
	heightMap = loadImage("heightmap.png")
	colorMap = loadImage("colormap.png")
	finalScreen = createGraphics(width, height, WEBGL)
	
	finalScreen.shader(shadowShader)
}

function draw() {
	shadowShader.setUniform("heightmap", heightMap)
	shadowShader.setUniform("colormap", colorMap)
	shadowShader.setUniform("sunPos", [mouseX / width, mouseY / height, 1])
	
	finalScreen.clear()
	finalScreen.rect(0, 0, width, height)
	
	image(finalScreen, 0, 0, width, height)
}
