import { useState } from 'react';
import { ethers } from 'ethers';

export default function Home() {
  const [price, setPrice] = useState('');
  const [status, setStatus] = useState('');

  // Contract ABI (Application Binary Interface)
  const contractABI = [
    "function setUserDefinedPrice(uint256 _price) external",
  ];

  // Function to handle form submission and interact with the contract
  const handleSubmit = async (event) => {
    event.preventDefault();

    // Make sure the user has entered a valid price
    if (!price || isNaN(price)) {
      setStatus('Please enter a valid number');
      return;
    }

    try {
      // Check if browser has MetaMask
      if (!window.ethereum) {
        setStatus('Please install MetaMask to interact with this contract');
        return;
      }

      // Request access to MetaMask account
      await window.ethereum.request({ method: 'eth_requestAccounts' });

      // Create an ethers.js provider and signer
      const provider = new ethers.providers.Web3Provider(window.ethereum);
      const signer = provider.getSigner();

      // Create a contract instance
      const contractAddress = process.env.NEXT_PUBLIC_CONTRACT_ADDRESS;
      const contract = new ethers.Contract(contractAddress, contractABI, signer);

      // Convert price to a uint256 format
      const priceInWei = ethers.utils.parseUnits(price, 'wei');

      // Call the contract function to set the price
      const tx = await contract.setUserDefinedPrice(priceInWei);
      setStatus('Transaction submitted! Waiting for confirmation...');

      // Wait for the transaction to be mined
      await tx.wait();

      setStatus('Price successfully updated!');
    } catch (error) {
      console.error(error);
      setStatus('An error occurred: ' + error.message);
    }
  };

  return (
    <div style={{ padding: '2rem' }}>
      <h1>Set Your Price</h1>
      <form onSubmit={handleSubmit}>
        <label>
          Desired Price (in wei):
          <input
            type="text"
            value={price}
            onChange={(e) => setPrice(e.target.value)}
            placeholder="Enter your price"
          />
        </label>
        <button type="submit">Submit</button>
      </form>
      <p>{status}</p>
    </div>
  );
}