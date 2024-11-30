import { describe, it, expect, beforeEach } from 'vitest';

// Mock implementation of the asset-verification contract
const AssetVerificationContract = {
  contractOwner: 'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM',
  verifiers: new Map(),
  assetVerifications: new Map(),
  blockHeight: 0,
  
  addVerifier(newVerifier, sender) {
    if (sender !== this.contractOwner) throw new Error('ERR-NOT-AUTHORIZED');
    this.verifiers.set(newVerifier, true);
    return { success: true };
  },
  
  removeVerifier(verifier, sender) {
    if (sender !== this.contractOwner) throw new Error('ERR-NOT-AUTHORIZED');
    this.verifiers.delete(verifier);
    return { success: true };
  },
  
  verifyAsset(assetId, verificationScore, notes, sender) {
    if (!this.verifiers.get(sender)) throw new Error('ERR-NOT-AUTHORIZED');
    if (verificationScore < 0 || verificationScore > 100) throw new Error('ERR-INVALID-SCORE');
    
    this.assetVerifications.set(assetId, {
      verifier: sender,
      verificationScore,
      timestamp: this.blockHeight,
      notes
    });
    return { success: true };
  },
  
  isVerifier(address) {
    return this.verifiers.get(address) || false;
  },
  
  getAssetVerification(assetId) {
    return this.assetVerifications.get(assetId) || null;
  },
  
  getContractOwner() {
    return this.contractOwner;
  },
  
  // Helper function to simulate block height changes
  incrementBlockHeight(amount = 1) {
    this.blockHeight += amount;
  }
};

describe('Asset Verification Contract', () => {
  const contractOwner = 'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM';
  const verifier1 = 'ST2CY5V39NHDPWSXMW9QDT3HC3GD6Q6XX4CFRK9AG';
  const verifier2 = 'ST3PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM';
  const unauthorizedUser = 'ST2REHHS5J3CERCRBEPMGH7NIY64H2HQWOKWVW9MP';
  
  beforeEach(() => {
    AssetVerificationContract.verifiers.clear();
    AssetVerificationContract.assetVerifications.clear();
    AssetVerificationContract.blockHeight = 0;
  });
  
  describe('Verifier Management', () => {
    it('should allow contract owner to add a verifier', () => {
      const result = AssetVerificationContract.addVerifier(verifier1, contractOwner);
      expect(result.success).toBe(true);
      expect(AssetVerificationContract.isVerifier(verifier1)).toBe(true);
    });
    
    it('should allow contract owner to remove a verifier', () => {
      AssetVerificationContract.addVerifier(verifier1, contractOwner);
      const result = AssetVerificationContract.removeVerifier(verifier1, contractOwner);
      expect(result.success).toBe(true);
      expect(AssetVerificationContract.isVerifier(verifier1)).toBe(false);
    });
    
    it('should not allow unauthorized users to add or remove verifiers', () => {
      expect(() => AssetVerificationContract.addVerifier(verifier1, unauthorizedUser)).toThrow('ERR-NOT-AUTHORIZED');
      expect(() => AssetVerificationContract.removeVerifier(verifier1, unauthorizedUser)).toThrow('ERR-NOT-AUTHORIZED');
    });
  });
  
  describe('Asset Verification', () => {
    beforeEach(() => {
      AssetVerificationContract.addVerifier(verifier1, contractOwner);
    });
    
    it('should allow a verifier to verify an asset', () => {
      const result = AssetVerificationContract.verifyAsset(1, 80, 'Good condition', verifier1);
      expect(result.success).toBe(true);
      const verification = AssetVerificationContract.getAssetVerification(1);
      expect(verification).toEqual({
        verifier: verifier1,
        verificationScore: 80,
        timestamp: 0,
        notes: 'Good condition'
      });
    });
    
    it('should not allow non-verifiers to verify assets', () => {
      expect(() => AssetVerificationContract.verifyAsset(1, 80, 'Good condition', unauthorizedUser)).toThrow('ERR-NOT-AUTHORIZED');
    });
    
    it('should not allow invalid verification scores', () => {
      expect(() => AssetVerificationContract.verifyAsset(1, 101, 'Invalid score', verifier1)).toThrow('ERR-INVALID-SCORE');
      expect(() => AssetVerificationContract.verifyAsset(1, -1, 'Invalid score', verifier1)).toThrow('ERR-INVALID-SCORE');
    });
  });
  
  describe('Read-only Functions', () => {
    it('should correctly report verifier status', () => {
      AssetVerificationContract.addVerifier(verifier1, contractOwner);
      expect(AssetVerificationContract.isVerifier(verifier1)).toBe(true);
      expect(AssetVerificationContract.isVerifier(verifier2)).toBe(false);
    });
    
    it('should return null for non-existent asset verifications', () => {
      expect(AssetVerificationContract.getAssetVerification(999)).toBeNull();
    });
    
    it('should return the correct contract owner', () => {
      expect(AssetVerificationContract.getContractOwner()).toBe(contractOwner);
    });
  });
});

