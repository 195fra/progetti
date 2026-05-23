import React from 'react';
import { NavigationContainer } from '@react-navigation/native';
import MyStacks from './navigation/MyStacks';
import { useCart } from './utils/cartStore';

export default function App() {
  // Il carrello vive qui — passato come prop alle schermate
  // Stesso pattern del progetto Pokemon
  const cart = useCart();

  return (
    <NavigationContainer>
      <MyStacks cart={cart} />
    </NavigationContainer>
  );
}
