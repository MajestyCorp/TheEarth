using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace TheEarth
{
    public class RotateAround : MonoBehaviour
    {
        [SerializeField, Header("Transform settings")]
        private Transform rotateAround;
        [SerializeField]
        private Transform rotateObject;

        [Header("Camera settings")]
        [SerializeField]
        private float minDistance = 1f;
        [SerializeField]
        private float maxDistance = 2f;
        [SerializeField]
        private float rotationAngleSpeed = 20f;
        [SerializeField]
        private float zoomSpeed = 1f;
        [SerializeField]
        private float zoomDampening = 5.0f;
        [SerializeField]
        private float rotateDampening = 10.0f;

        private float _currentDistance;
        private float _desiredDistance;
        private Quaternion _desiredRotation;
        private Vector3 _cameraAngles;
        private float _deltaDistance;

        private void Awake()
        {
            Init();
        }

        private void Init()
        {
            _desiredDistance = _currentDistance = maxDistance;

            _cameraAngles = rotateObject.localRotation.eulerAngles;
            _desiredRotation = Quaternion.Euler(_cameraAngles);

            _deltaDistance = maxDistance - minDistance;
        }

        private void LateUpdate()
        {
            HandleRotation();
            HandleZoom();
            MoveToDesired();
        }

        private void HandleRotation()
        {
            if (Input.GetMouseButton(0))
            {
                _cameraAngles.y += Input.GetAxis("Mouse X") * rotationAngleSpeed * Time.deltaTime;
                _cameraAngles.x -= Input.GetAxis("Mouse Y") * rotationAngleSpeed * Time.deltaTime;

                _cameraAngles.x = Mathf.Clamp(_cameraAngles.x, -90f, 90f);
                _desiredRotation = Quaternion.Euler(_cameraAngles);
            }
        }

        private void HandleZoom()
        {
            float mouseWheel = Input.GetAxis("Mouse ScrollWheel");

            _desiredDistance -= _deltaDistance * mouseWheel * zoomSpeed;
            _desiredDistance = Mathf.Clamp(_desiredDistance, minDistance, maxDistance);
        }

        private void MoveToDesired()
        {
            //calc rotation
            rotateObject.localRotation = Quaternion.Lerp(rotateObject.localRotation, _desiredRotation, Time.deltaTime * rotateDampening);

            // calc desired distance
            _currentDistance = Mathf.Lerp(_currentDistance, _desiredDistance, Time.deltaTime * zoomDampening);

            rotateObject.localPosition = -rotateObject.forward * _currentDistance;

        }
    }
}