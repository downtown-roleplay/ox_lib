import { useNuiEvent } from '../../../hooks/useNuiEvent';
import { Box, createStyles, Flex, Stack, Text } from '@mantine/core';
import { useEffect, useState } from 'react';
import { ContextMenuProps } from '../../../typings';
import ContextButton from './components/ContextButton';
import { fetchNui } from '../../../utils/fetchNui';
import ReactMarkdown from 'react-markdown';
import HeaderButton from './components/HeaderButton';
import ScaleFade from '../../../transitions/ScaleFade';
import MarkdownComponents from '../../../config/MarkdownComponents';

const openMenu = (id: string | undefined) => {
  fetchNui<ContextMenuProps>('openContext', { id: id, back: true });
};

const useStyles = createStyles(() => ({
  container: {
    position: 'absolute',
    top: '15%',
    right: '25%',
    width: 410,
    fontFamily: 'var(--dt-font-body)',
  },
  panel: {
    backgroundColor: 'var(--dt-panel)',
    border: '1px solid var(--dt-hairline-strong)',
    borderRadius: 2,
    boxShadow: 'var(--dt-shadow-panel)',
    overflow: 'hidden',
  },
  header: {
    alignItems: 'center',
    justifyContent: 'space-between',
    gap: 4,
    padding: '13px 10px 11px',
  },
  titleText: {
    flex: 1,
    textAlign: 'center',
    color: 'var(--dt-text)',
    fontFamily: 'var(--dt-font-display)',
    fontSize: 18,
    textTransform: 'uppercase',
    letterSpacing: '0.18em',
    textShadow: 'var(--dt-shadow-text)',
  },
  buttonsContainer: {
    maxHeight: 540,
    overflowY: 'scroll',
    '::-webkit-scrollbar': { display: 'none' },
  },
  buttonsFlexWrapper: {
    gap: 0,
  },
}));

const ContextMenu: React.FC = () => {
  const { classes } = useStyles();
  const [visible, setVisible] = useState(false);
  const [contextMenu, setContextMenu] = useState<ContextMenuProps>({
    title: '',
    options: { '': { description: '', metadata: [] } },
  });

  const closeContext = () => {
    if (contextMenu.canClose === false) return;
    setVisible(false);
    fetchNui('closeContext');
  };

  // Hides the context menu on ESC
  useEffect(() => {
    if (!visible) return;

    const keyHandler = (e: KeyboardEvent) => {
      if (['Escape'].includes(e.code)) closeContext();
    };

    window.addEventListener('keydown', keyHandler);

    return () => window.removeEventListener('keydown', keyHandler);
  }, [visible]);

  useNuiEvent('hideContext', () => setVisible(false));

  useNuiEvent<ContextMenuProps>('showContext', async (data) => {
    if (visible) {
      setVisible(false);
      await new Promise((resolve) => setTimeout(resolve, 100));
    }
    setContextMenu(data);
    setVisible(true);
  });

  return (
    <Box className={classes.container}>
      <ScaleFade visible={visible}>
        <Box className={`${classes.panel} dt-grain`}>
          <Flex className={classes.header}>
            <HeaderButton
              icon="chevron-left"
              iconSize={18}
              hidden={!contextMenu.menu}
              handleClick={() => openMenu(contextMenu.menu)}
            />
            <Text className={classes.titleText}>
              <ReactMarkdown components={MarkdownComponents}>{contextMenu.title}</ReactMarkdown>
            </Text>
            <HeaderButton icon="xmark" canClose={contextMenu.canClose} iconSize={18} handleClick={closeContext} />
          </Flex>
          <div className="dt-rule" />
          <Box className={classes.buttonsContainer}>
            <Stack className={classes.buttonsFlexWrapper}>
              {Object.entries(contextMenu.options).map((option, index) => (
                <ContextButton option={option} key={`context-item-${index}`} />
              ))}
            </Stack>
          </Box>
        </Box>
      </ScaleFade>
    </Box>
  );
};

export default ContextMenu;
