#include "fps_camera.h"


FPSCamera::FPSCamera() {
	currentTransformation.orientation = Quaternion();
	projectionMatrix = glm::perspective(glm::radians(70.0f),16.0f / 9.0f, 0.1f,100.0f);
	currentTransformation.position = glm::vec3(0.0f, 2.0f, 8.0f);
	startY = currentTransformation.position.y;
}

void FPSCamera::translate(float dx, float dz, float dt)
{

	vec3 velocity = vec3(dx,0,dz) * cameraSpeed;
	currentTransformation.position += velocity * dt;

}

void FPSCamera::turn(vec2 relMouseMovement)
{
	float dx = sensitivity * relMouseMovement.x;
	float dy = sensitivity * relMouseMovement.y;

	Quaternion rotx(vec3(0, 1, 0), dx);
	Quaternion roty(vec3(1, 0, 0), dy);
	//printf("%.20f %.20f\n", dx, dy);

	Quaternion newOrientation = currentTransformation.orientation;
	newOrientation = rotx*(newOrientation*roty);

	currentTransformation.orientation = newOrientation;
	lastTransformation.orientation = currentTransformation.orientation;

}

void FPSCamera::updatePosition(float dt)
{
	Object::update();

	const Uint8 *keyBoardState = SDL_GetKeyboardState(NULL);

	bool dPressed = keyBoardState[SDL_SCANCODE_D]; // example of how to get the keystate
	bool wPressed = keyBoardState[SDL_SCANCODE_W]; 
	bool aPressed = keyBoardState[SDL_SCANCODE_A]; 
	bool sPressed = keyBoardState[SDL_SCANCODE_S]; 

	if(wPressed) translate(0, -1, dt);
	if(aPressed) translate(-1, 0, dt);
	if(sPressed) translate(0, 1, dt);
	if(dPressed) translate(1, 0, dt);

	bool spacePressed = keyBoardState[SDL_SCANCODE_SPACE];

	float& y = currentTransformation.position.y;
	if(spacePressed && y == startY){
		vy = 7;
	}

        y = max(y + vy*dt, startY);
	vy -= 9.81*dt;

}

void FPSCamera::updateOrientation(bool capture)
{
	int mouseX, mouseY;
	Uint32 buttons = SDL_GetMouseState(&mouseX, &mouseY);

	glm::vec2 newMousePos = glm::vec2(mouseX,mouseY);
	glm::vec2 relMovement = prevMousePosition - newMousePos;

	if (capture || SDL_BUTTON(SDL_BUTTON_LEFT) & buttons)
	{
		turn(relMovement);
	}
	prevMousePosition = newMousePos;
}

