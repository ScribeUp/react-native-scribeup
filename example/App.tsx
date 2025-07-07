import { useState } from 'react';
import {
  Button,
  KeyboardAvoidingView,
  Platform,
  ScrollView,
  StyleSheet,
  Text,
  TextInput,
  View,
} from 'react-native';
import ScribeUp from '@scribeup/react-native-scribeup'

export default function App() {
  const [url, setUrl] = useState(
    'https://alpha.widget.scribeup.io/preview#eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicHJldmlldyIsImV4cCI6MTc2NjQ0NzQ2MCwiaWF0IjoxNzUwODk1NDYwLCJqdGkiOiJmODVjZjlkNTUxNWQ0ZjVjODc0NmUwOTRmOWU2ZGQ1NCIsInVzZXJfaWQiOiI5NjA5OGQ1MS0xNGFmLTQzMTgtYjVlYS1iYmFiOGMzYWU1NDYifQ.dnnO8XD1ypjnJN0K7_Z5VWA_kLV_B3eJ3-JVWi5iXtU'
  );
  const [productName, setProductName] = useState('');
  const [showScribeup, setShowScribeup] = useState(false);

  const onExitHandler = (data?: { message?: string; code?: number }) => {
    console.log('onExitHandler', data);
    setShowScribeup(false);
  };

  const handleOpenScribeup = () => {
    setShowScribeup(true);
  };

  return (
    <View style={styles.container}>
      <KeyboardAvoidingView
        style={styles.container}
        behavior={Platform.OS === 'ios' ? 'padding' : undefined}
      >
        <ScrollView contentContainerStyle={styles.scrollContainer}>
          <View style={styles.container}>
            <Text style={styles.title}>ScribeUp Demo</Text>
            <Text style={styles.description}>
              This is an example of integration with ScribeUp SDK. Enter the
              values and press the button to open the subscription interface.
            </Text>

            <Text style={styles.label}>ScribeUp URL:</Text>
            <TextInput
              style={styles.input}
              value={url}
              onChangeText={setUrl}
              placeholder="Enter ScribeUp URL"
              autoCapitalize="none"
              autoCorrect={false}
            />

            <Text style={styles.label}>Product Name:</Text>
            <TextInput
              style={styles.input}
              value={productName}
              onChangeText={setProductName}
              placeholder="Enter product name"
            />

            <Button title="Open ScribeUp" onPress={handleOpenScribeup} />
          </View>
        </ScrollView>
      </KeyboardAvoidingView>
      {showScribeup && (
        <ScribeUp url={url} productName={productName} onExit={onExitHandler} />
      )}
    </View>
  );
}

const styles = StyleSheet.create({
  scrollContainer: {
    flexGrow: 1,
    width: '100%',
  },
  container: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'stretch',
    padding: 20,
    width: '100%',
  },
  title: {
    fontSize: 24,
    fontWeight: 'bold',
    marginBottom: 20,
    alignSelf: 'center',
  },
  description: {
    textAlign: 'center',
    marginBottom: 30,
    color: '#666',
  },
  label: {
    alignSelf: 'flex-start',
    fontWeight: '600',
    marginBottom: 8,
    width: '100%',
  },
  input: {
    width: '100%',
    height: 44,
    borderWidth: 1,
    borderColor: '#ccc',
    borderRadius: 8,
    marginBottom: 20,
    paddingHorizontal: 10,
  },
});