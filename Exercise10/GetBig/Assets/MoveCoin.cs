using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class MoveCoin : MonoBehaviour
{
    private GameObject Ball_ref;
    private float Orig_y;
    // Start is called before the first frame update
    void Start()
    {
        Ball_ref = GameObject.Find("Ball");
        Orig_y = this.transform.position.z;
    }

    // Update is called once per frame
    void Update()
    {
        transform.Translate(new Vector3(0, 0, -Mathf.Sin(Time.time*2)/33));
        transform.Rotate(Vector3.back*10);

    }
    private void OnTriggerEnter(Collider other)
    {
        if (other.gameObject == Ball_ref)
        {
            Destroy(this.gameObject);
            other.transform.localScale += new Vector3(0.1f, 0.1f, 0.1f);
        }
    }
}
