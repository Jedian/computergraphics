using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class SpawnCoins : MonoBehaviour
{
    public GameObject Coin;
    // Start is called before the first frame update
    void Start()
    {
        InvokeRepeating("SpawnCoin", 0, 1f);
    }

    // Update is called once per frame
    void Update()
    {
        
    }

    private void SpawnCoin()
    {
        Vector3 vector3 = new Vector3(Random.Range(-4, 4), Random.Range(0, 3), Random.Range(-4, 4));
        Object.Instantiate(Coin, vector3, Coin.gameObject.transform.rotation);
        if (this.transform.localScale.x > 0.5f) this.transform.localScale *= 0.99f;
    }
}
