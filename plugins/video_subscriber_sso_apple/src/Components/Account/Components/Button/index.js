import { Platform } from 'react-native';
import TVButton from './TVButton';
import MobileButton from './MobileButton';

const isTV = Platform.isTV || Platform.OS === 'web';

const Button = isTV ? TVButton : MobileButton;

export default Button;
