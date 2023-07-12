// SPDX-License-Identifier: MIT
pragma solidity  ^0.8.0;

/*
--> Here we are trying to produce a Mercle Tree
--> Using that we can use Merkle Proof for verifications 
--> Here using the proof, we can check if a certain data was included in a set of data 
*/
contract Proof {

    /*
    --> the verify function takes in 4 parameters 
    1) proof []  -> array of hashes to compute the mercle root
    2) root -> the root itself 
    3) leaf -> The hash of the element in the array that was used to construct the merkle tree
    4) index -> the index of the element in the array, where the element is stored 

    returns --> Returns true if it can recreate tth proof from the given inputs 
    */
    function verify(bytes32[] memory proof, bytes32 root, bytes32 leaf , uint256 index ) public pure returns (bool) {
        bytes32 hash = leaf;

        // recompute the merkle tree 
        for (uint i = 0; i < proof.length; i++) 
        {
            // Here we know the index of the left leaves are all even and the index of the right leaves are all odd  
            // To compute the pairing hashes
            if (index % 2 == 0) {
                // since the index is even 
                // we need to append the proof_element to the current hash and then apppend the hash 
                hash = keccak256(abi.encodePacked(hash,proof[i]));
            }
            else {
                hash = keccak256(abi.encodePacked(proof[i],hash));
            }

            index = index / 2;
        }

        return hash == root;
    }
}

contract TestMerkleProof is Proof {
    bytes32[] private hashes;

    constructor() {
        string[4] memory transactions = [
            "alice -> bob",
            "bob -> dave",
            "carol -> alice",
            "dave -> bob"
        ];

        // Here i am generating the hashes of the transactions array elements 
        for (uint i = 0; i < transactions.length; i++) {
            hashes.push(keccak256(abi.encodePacked(transactions[i])));
        }

        uint n = transactions.length;
        uint offset = 0;

        // Here i am creating the merkle Tree of the elements 
        while (n > 0) {
            // incrementing i by 2 bcoz the merkle tree works in pairs and the hashes a
            for (uint i = 0; i < n - 1; i += 2) {
                hashes.push(
                    keccak256(
                        abi.encodePacked(hashes[offset + i], hashes[offset + i + 1])
                    )
                );
            }
            offset += n;
            n = n / 2;
        }
    }

    function getRoot() public view returns (bytes32) {
        return hashes[hashes.length - 1];
    }

    function getHashes(uint256 index) public view returns (bytes32) {
         return hashes[index];
     }


    /* verify
    3rd leaf
    0xdca3326ad7e8121bf9cf9c12333e6b2271abe823ec9edfe42f813b1e768fa57b

    root
    0xcc086fcc038189b4641db2cc4f1de3bb132aefbd65d510d817591550937818c7

    index
    2

    proof
    0x8da9e1c820f9dbd1589fd6585872bc1063588625729e7ab0797cfc63a00bd950 -> index 3 hash 
    0x995788ffc103b987ad50f5e5707fd094419eb12d9552cc423bd0cd86a3861433 -> index 4 hash (hash of index0 and index1)
    */
}
