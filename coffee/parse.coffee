acorn = require('../lib/acorn.js')
walk = require('../lib/walk.js')

getItemAt = (src, row, col) ->
  pos = 0
  lines = src.split '\n'
  for r in [0...row]
    pos += lines[r].length
  pos += col

  src = 'x = ' + src
  pos += 4

  ast = acorn.parse src,
    sourceType: 'script'
    locations: true

  node = walk.findNodeAround(ast, pos).node

  root = ast.body[0].expression.right

  Found = (@path, @node) ->

  try
    walk = (start, path='') ->
      if start?.key?.value?
        if path
          path += '.'
        path += start.key.value

      if start is node
        throw new Found(path, node)

      switch start.type
        when 'Property'
          walk(start.value, path)

        when 'ObjectExpression'
          for prop in start.properties
            walk(prop, path)

        when 'ArrayExpression'
          if path
            path += '.'
          for el, i in start.elements
            walk(el, path + i)

    walk root
  catch e
    if e instanceof Found
      return e

    throw e

  return null

module.exports = {getItemAt}
