import { Box, Button, Group, Modal, Text, Title } from '@mantine/core';
import { useNuiEvent } from '../../hooks/useNuiEvent';
import { fetchNui } from '../../utils/fetchNui';
import { useState } from 'react';
import ReactMarkdown from 'react-markdown';
import type { AlertProps } from '../../typings';
import classes from './AlertDialog.module.css';

const playSound = () => {
  const audio = new Audio('https://www.myinstants.com/media/sounds/button-click.mp3');
  audio.play();
};

const AlertDialog: React.FC = () => {
  const [opened, setOpened] = useState(false);
  const [dialogData, setDialogData] = useState<AlertProps>({
    header: '',
    content: '',
  });

  const openDialog = (data: AlertProps) => {
    setDialogData(data);
    setOpened(true);
  };

  // Evento do ox_lib original
  useNuiEvent<AlertProps>('sendAlert', openDialog);

  // Evento alternativo (caso seja chamado de outro lugar)
  useNuiEvent<AlertProps>('openAlertDialog', openDialog);

  useNuiEvent('closeAlertDialog', () => {
    setOpened(false);
  });

  const handleClose = (button: 'confirm' | 'cancel') => {
    playSound();
    setOpened(false);
    fetchNui('closeAlert', button);
  };

  return (
    <Modal
      opened={opened}
      centered={dialogData.centered}
      size={dialogData.size || 'sm'}
      withCloseButton={false}
      closeOnClickOutside={false}
      onClose={() => {
        setOpened(false);
        fetchNui('closeAlert', 'cancel');
      }}
      classNames={{
        root: classes.root,
        modal: classes.content,
        overlay: classes.overlay,
        body: classes.body,
      }}
    >
      {/* Corner ornaments */}
      <div className={classes.cornerTL} aria-hidden="true" />
      <div className={classes.cornerTR} aria-hidden="true" />
      <div className={classes.cornerBL} aria-hidden="true" />
      <div className={classes.cornerBR} aria-hidden="true" />

      {/* Header */}
      <Box className={classes.header}>
        <div className={classes.headerLine} />
        <Title order={4} className={classes.title}>
          {dialogData.header}
        </Title>
        <div className={classes.headerLine} />
      </Box>

      {/* Divider top */}
      <div className={classes.divider}>
        <span className={classes.dividerIcon}>✦</span>
      </div>

      {/* Content body */}
      <Box className={classes.bodyContent}>
        <Text className={classes.contentText}>
          <ReactMarkdown>{dialogData.content}</ReactMarkdown>
        </Text>
      </Box>

      {/* Divider bottom */}
      <div className={classes.divider}>
        <span className={classes.dividerIcon}>✦</span>
      </div>

      {/* Footer buttons */}
      <Group className={classes.footer} position="center">
        {dialogData.cancel && (
          <Button
            className={`${classes.btn} ${classes.btnCancel}`}
            onClick={() => handleClose('cancel')}
          >
            {dialogData.labels?.cancel ?? 'Cancelar'}
          </Button>
        )}
        <Button
          className={`${classes.btn} ${classes.btnConfirm}`}
          onClick={() => handleClose('confirm')}
        >
          {dialogData.labels?.confirm ?? 'Confirmar'}
        </Button>
      </Group>
    </Modal>
  );
};

export default AlertDialog;