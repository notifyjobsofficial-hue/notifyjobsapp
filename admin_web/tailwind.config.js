/** @type {import('tailwindcss').Config} */
export default {
  content: ['./index.html', './src/**/*.{js,ts,jsx,tsx}'],
  theme: {
    extend: {
      colors: {
        brand: {
          50: '#F0FDF4',
          100: '#DCFCE7',
          200: '#BBF7D0',
          300: '#86EFAC',
          400: '#4ADE80',
          500: '#159B76', // Primary #159B76
          600: '#117A5E', // Primary Dark #117A5E
          700: '#0F664F',
          800: '#064E3B',
          900: '#022C22',
        },
        navy: '#0F172A',
        slate: {
          750: '#293548',
          850: '#172033',
        },
      },
      fontFamily: {
        sans: ['Inter', 'system-ui', '-apple-system', 'sans-serif'],
      },
    },
  },
  plugins: [],
};
