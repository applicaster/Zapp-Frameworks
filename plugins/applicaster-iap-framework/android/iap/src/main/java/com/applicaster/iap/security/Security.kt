package com.applicaster.iap.security

import android.util.Base64
import android.util.Log
import java.io.IOException
import java.security.*
import java.security.spec.X509EncodedKeySpec

class Security {

    companion object {

        private val TAG = Security::class.java.canonicalName

        private const val KEY_FACTORY_ALGORITHM = "RSA"
        private const val SIGNATURE_ALGORITHM = "SHA1withRSA"

        /**
         * Verifies that the data was signed with the given signature, and returns the verified
         * purchase.
         * @param base64PublicKey the base64-encoded public key to use for verifying.
         * @param signedData the signed JSON string (signed, not encrypted)
         * @param signature the signature for the data, signed with the private key
         * @throws IOException if encoding algorithm is not supported or key specification
         * is invalid
         */
        @Throws(IOException::class)
        fun verifyPurchase(
            base64PublicKey: String,
            signedData: String,
            signature: String
        ): Boolean {
            if (signedData.isEmpty() || base64PublicKey.isEmpty() || signature.isEmpty()
            ) {
                Log.w(TAG, "Input fields should be filled!")
                return false
            }

            val key = generatePublicKey(base64PublicKey)
            return key?.let { verify(it, signedData, signature) } ?: false
        }

        /**
         * Generates a PublicKey instance from a string containing the Base64-encoded public key.
         *
         * @param encodedPublicKey Base64-encoded public key
         * @throws IOException if encoding algorithm is not supported or key specification
         * is invalid
         */
        @Throws(IOException::class)
        private fun generatePublicKey(encodedPublicKey: String): PublicKey? {
            val publicKey: PublicKey? = null

            runCatching {
                val decodedKey = Base64.decode(encodedPublicKey, Base64.DEFAULT)
                val keyFactory = KeyFactory.getInstance(KEY_FACTORY_ALGORITHM)
                return keyFactory.generatePublic(X509EncodedKeySpec(decodedKey))
            }.onFailure {
                Log.w(TAG, "Error: ${it.localizedMessage}")
            }
            return publicKey
        }

        /**
         * Verifies that the signature from the server matches the computed signature on the data.
         * Returns true if the data is correctly signed.
         *
         * @param publicKey public key associated with the developer account
         * @param signedData signed data from server
         * @param signature server signature
         * @return true if the data and signature match
         */
        private fun verify(publicKey: PublicKey, signedData: String, signature: String): Boolean {

            runCatching {
                val signatureBytes = Base64.decode(signature, Base64.DEFAULT)
                val signatureAlgorithm = Signature.getInstance(SIGNATURE_ALGORITHM)
                signatureAlgorithm.initVerify(publicKey)
                signatureAlgorithm.update(signedData.toByteArray())
                if (!signatureAlgorithm.verify(signatureBytes)) {
                    Log.w(TAG, "Signature verification failed.")
                    return false
                }
                return true
            }.onFailure {
                Log.w(TAG, "Error: ${it.localizedMessage}")
            }
            return false
        }

    }
}