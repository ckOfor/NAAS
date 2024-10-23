# Physical Asset Authentication System

A Clarity smart contract for authenticating and managing physical assets on the Stacks blockchain. This system allows users to create digital representations of physical assets, track their ownership, location, and condition, as well as enable buying and selling of these assets.

## Features

- **Asset Management**
    - Mint new physical assets with metadata and location information
    - Update asset location
    - Track asset condition
    - View asset details

- **Marketplace Functionality**
    - List assets for sale
    - Unlist assets from the marketplace
    - Purchase listed assets
    - View listing details

- **Administrative Controls**
    - Contract owner management
    - Asset ownership verification

## Contract Functions

### Administrative Functions

- `set-contract-owner`: Update the contract owner
  ```clarity
  (set-contract-owner new-owner-principal)
  ```

### Asset Management

- `mint-asset`: Create a new physical asset
  ```clarity
  (mint-asset metadata location)
  ```

- `update-location`: Update an asset's location
  ```clarity
  (update-location asset-id new-location)
  ```

### Marketplace Functions

- `list-asset`: List an asset for sale
  ```clarity
  (list-asset asset-id price)
  ```

- `unlist-asset`: Remove an asset from sale
  ```clarity
  (unlist-asset asset-id)
  ```

- `purchase-asset`: Buy a listed asset
  ```clarity
  (purchase-asset asset-id)
  ```

### Read-Only Functions

- `get-asset-details`: Retrieve asset information
  ```clarity
  (get-asset-details asset-id)
  ```

- `get-listing`: Get marketplace listing details
  ```clarity
  (get-listing asset-id)
  ```

- `get-owner`: Get contract owner
  ```clarity
  (get-owner)
  ```

## Error Codes

- `ERR-NOT-AUTHORIZED (u100)`: User not authorized to perform action
- `ERR-ASSET-NOT-FOUND (u101)`: Asset ID does not exist
- `ERR-ALREADY-LISTED (u102)`: Asset is already listed for sale
- `ERR-NOT-LISTED (u103)`: Asset is not listed for sale
- `ERR-INVALID-PRICE (u104)`: Invalid price specified for listing

## Data Structures

### PhysicalAssets Map
```clarity
{
    owner: principal,
    metadata: (string-utf8 256),
    location: (string-utf8 100),
    condition: uint,
    is-listed: bool
}
```

### AssetListings Map
```clarity
{
    price: uint,
    seller: principal
}
```

## Usage Example

1. Mint a new asset:
```clarity
(contract-call? .physical-asset-auth mint-asset "Serial: ABC123, Type: Widget" "Warehouse A")
```

2. List asset for sale:
```clarity
(contract-call? .physical-asset-auth list-asset u1 u1000)
```

3. Purchase asset:
```clarity
(contract-call? .physical-asset-auth purchase-asset u1)
```

## Security Considerations

- Only asset owners can list, unlist, or update their assets
- Contract owner has administrative privileges
- Asset ownership transfers are verified before execution
- Price must be greater than zero for listings

## Notes

- Asset metadata is limited to 256 characters
- Location information is limited to 100 characters
- Asset condition is represented as an unsigned integer (0-100)
- All monetary values are in microSTX

## Contributing

Feel free to submit issues and enhancement requests.

## License

[Specify your license here]
