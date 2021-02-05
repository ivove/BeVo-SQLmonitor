import React from 'react';
import PropTypes from 'prop-types';
import clsx from 'clsx';
import {
  Box,
  Card,
  CardContent,
  FormGroup,
  TextField,
  InputAdornment,
  SvgIcon,
  Checkbox,
  FormControlLabel,
  makeStyles
} from '@material-ui/core';
import { Search as SearchIcon } from 'react-feather';

const useStyles = makeStyles((theme) => ({
  root: {},
  importButton: {
    marginRight: theme.spacing(1)
  },
  exportButton: {
    marginRight: theme.spacing(1)
  }
}));

const Toolbar = ({ className, ...rest }) => {
  const classes = useStyles();

  return (
    <div
      className={clsx(classes.root, className)}
      {...rest}
    >
      <Box mt={3}>
        <Card>
          <CardContent>
            <FormGroup row>
              <Box width={500}>
                <TextField
                  fullWidth
                  InputProps={{
                    startAdornment: (
                      <InputAdornment position="start">
                        <SvgIcon
                          fontSize="small"
                          color="action"
                        >
                          <SearchIcon />
                        </SvgIcon>
                      </InputAdornment>
                    )
                  }}
                  placeholder="Search query"
                  variant="outlined"
                />
              </Box>
              <Box flexGrow={1} />
              <Box>
                <FormControlLabel
                  control={(
                    <Checkbox defaultChecked />
                  )}
                  label="Class Query"
                />
              </Box>
              <Box>
                <FormControlLabel
                  control={(
                    <Checkbox defaultChecked />
                  )}
                  label="Embedded SQL"
                />
              </Box>
              <Box>
                <FormControlLabel
                  control={(
                    <Checkbox defaultChecked />
                  )}
                  label="SQL Statement"
                />
              </Box>
            </FormGroup>
          </CardContent>
        </Card>
      </Box>

    </div>
  );
};

Toolbar.propTypes = {
  className: PropTypes.string
};

export default Toolbar;
