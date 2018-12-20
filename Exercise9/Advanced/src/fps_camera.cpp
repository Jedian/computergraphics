#include "fps_camera.h"


FPSCamera::FPSCamera() {
	currentTransformation.orientation = Quaternion();
	projectionMatrix = glm::perspective(glm::radians(70.0f),16.0f / 9.0f, 0.1f,100.0f);
	currentTransformation.position = glm::vec3(0.0f, 2.0f, 8.0f);
	startY = currentTransformation.position.y;
}

void FPSCamera::translate(float dx, float dz, float dt)
{

	// TODO 9.4 a)
	// Compute the correct velocity vector and integrate the position with it.
	// The parameters dx and dz give the motion along the local x and z axis.
	// Make sure that the final velocity is parallel to the x-z plane.
	// Take cameraSpeed into account.

	//Change these two lines...
	vec3 velocity = vec3(dx,0,dz) * cameraSpeed;
	currentTransformation.position += velocity * dt;

}

void FPSCamera::turn(vec2 relMouseMovement)
{
	float dx = sensitivity * relMouseMovement.x;
	float dy = sensitivity * relMouseMovement.y;

	// TODO 9.4 b)
	// Implement the camera turning with the mouse.
	// - Create the quaternions representing the x and y axis rotation.
	// - The local x axis of the camera must always be parallel to the ground!
	// - Forbid upside-down turning: (newOrientation * vec3(0,1,0)).y should be > 0.
	//	 Otherwise, only use the rotation around the y axis.
	Quaternion rotx(vec3(0, 1, 0), dx);
	Quaternion roty(vec3(1, 0, 0), dy);
	printf("%.20f %.20f\n", dx, dy);

	// compute newOrientation from currentTransformation.orientation
	Quaternion newOrientation;
	newOrientation = roty*(currentTransformation.orientation*rotx);


	// When you are done, set current transformation and last transformation so that we do not interpolate mouse motion
	// (Don't change these two lines!).
	currentTransformation.orientation = newOrientation;
	lastTransformation.orientation = currentTransformation.orientation;

}

void FPSCamera::updatePosition(float dt)
{
	Object::update();

	const Uint8 *keyBoardState = SDL_GetKeyboardState(NULL);

	// TODO 9.4 a)
	// Read the keyboard state and call the translate function with the correct parameters.
	// Keys - Action
	// W - Forward
	// S - Backward
	// A - Left
	// D - Right
	bool dPressed = keyBoardState[SDL_SCANCODE_D]; // example of how to get the keystate
	bool wPressed = keyBoardState[SDL_SCANCODE_W]; 
	bool aPressed = keyBoardState[SDL_SCANCODE_A]; 
	bool sPressed = keyBoardState[SDL_SCANCODE_S]; 

	if(wPressed) translate(0, -1, dt);
	if(aPressed) translate(-1, 0, dt);
	if(sPressed) translate(0, 1, dt);
	if(dPressed) translate(1, 0, dt);

	// TODO 9.4 c)
	// Implement a simple jumping behaviour when pressing "space" (= SDL_SCANCODE_SPACE).
	// - Use the member variables "vy" and "startY".
	// - vy is the vertical current velocity.
	// - startY is the height of the camera when it is on the ground.
	// - Change y according to vy.
	// - Change vy according to the earth acceleration.
	// - y should not drop below startY.
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

