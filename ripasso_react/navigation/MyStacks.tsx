import React from 'react';
import { createNativeStackNavigator } from '@react-navigation/native-stack';
import HomeScreen from '../screens/HomeScreen';
import ProductDetailScreen from '../screens/ProductDetailScreen';
import CartScreen from '../screens/CartScreen';
import { CartItem, Product } from '../utils/types';

export type MyStackParamList = {
  Home: undefined;
  ProductDetail: { productId: number };
  Cart: undefined;
};

// Il carrello viene passato come prop alle schermate che ne hanno bisogno.
// Stesso pattern semplice del progetto Pokemon.
export type CartProps = {
  cartItems: CartItem[];
  totalItems: number;
  totalPrice: number;
  addToCart: (product: Product) => void;
  removeFromCart: (productId: number) => void;
  updateQuantity: (productId: number, quantity: number) => void;
  clearCart: () => void;
};

const Stack = createNativeStackNavigator<MyStackParamList>();

export default function MyStacks({ cart }: { cart: CartProps }) {
  return (
    <Stack.Navigator
      initialRouteName="Home"
      screenOptions={{
        headerStyle: { backgroundColor: '#3D5AFE' },
        headerTintColor: '#FFFFFF',
        headerTitleStyle: { fontWeight: 'bold' },
      }}
    >
      <Stack.Screen name="Home" options={{ title: 'Catalogo Prodotti' }}>
        {props => <HomeScreen {...props} cart={cart} />}
      </Stack.Screen>

      <Stack.Screen name="ProductDetail" options={{ title: 'Dettaglio Prodotto' }}>
        {props => <ProductDetailScreen {...props} addToCart={cart.addToCart} />}
      </Stack.Screen>

      <Stack.Screen name="Cart" options={{ title: 'Il mio carrello' }}>
        {props => <CartScreen {...props} cart={cart} />}
      </Stack.Screen>
    </Stack.Navigator>
  );
}
