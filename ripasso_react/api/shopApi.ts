import axios from 'axios';
import { Product } from '../utils/types';

const api = axios.create({ baseURL: 'https://api.escuelajs.co/api/v1' });

export async function getProductList(): Promise<Product[]> {
  const res = await api.get('/products?limit=30');
  return res.data.filter((p: Product) => p.images?.length > 0 && p.category?.name);
}

export async function getProductDetail(id: number): Promise<Product> {
  const res = await api.get(`/products/${id}`);
  return res.data;
}

// La Platzi API a volte restituisce le immagini come '["url"]'
export function cleanImage(raw: string): string {
  if (!raw) return '';
  if (raw.startsWith('[')) {
    return raw.replace(/[\[\]"\\]/g, '').split(',')[0].trim();
  }
  return raw;
}
