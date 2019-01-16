using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class MovePlane : MonoBehaviour
{
    // Start is called before the first frame update

    private Rigidbody rigidBody;
    void Start()
    {
        rigidBody = gameObject.GetComponent<Rigidbody>();
    }

    // Update is called once per frame
    void Update()
    {
        float vertical = Input.GetAxis("Vertical");
        float horizontal = Input.GetAxis("Horizontal");

		Debug.Log("Vertical: " + vertical);
		Debug.Log("Horizontal: " + horizontal);

		Debug.Log(transform.position);

		var dir = transform.TransformDirection(Vector3.down);
		var pos = transform.position;

		if (horizontal > 0)
			pos[0] = 1;
		else if (horizontal < 0)
			pos[0] = -1;

		if (vertical > 0)
			pos[2] = 1;
		else if (vertical < 0)
			pos[2] = -1;

		rigidBody.AddForceAtPosition(dir, transform.TransformPoint(pos));
    }
}
