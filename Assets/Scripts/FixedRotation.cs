using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace TheEarth
{
    public class FixedRotation : MonoBehaviour
    {
        [SerializeField]
        private Vector3 anglesSpeed;

        void Update()
        {
            transform.rotation *= Quaternion.Euler(anglesSpeed * Time.deltaTime);
        }
    }
}